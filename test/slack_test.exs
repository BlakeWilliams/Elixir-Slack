defmodule SlackTest do
  use ExUnit.Case

  defmodule Bot do
    use Slack
  end

  defmodule FakeWebsocketClient do
    def send({:text, json}, socket) do
      {json, socket}
    end
  end

  test "on_connect returns state by default" do
    assert Bot.handle_connect(nil, 1) == {:ok, 1}
  end

  test "handle_message returns state by default" do
    assert Bot.handle_message(nil, nil, 1) == {:ok, 1}
  end

  test "send_raw sends slack formatted to client" do
    result = Slack.send_raw(~s/{"text": "foo"}/, %{socket: nil}, FakeWebsocketClient)
    assert result == {~s/{"text": "foo"}/, nil}
  end

  test "init formats rtm results properly" do
    rtm = %{
      self: %{name: "fake"},
      team: %{name: "Foo"},
      bots: [%{id: "123"}],
      channels: [%{id: "123"}],
      groups: [%{id: "123"}],
      users: [%{id: "123"}],
    }

    {:ok, %{slack: slack, state: state}} = Bot.init(%{rtm: rtm, state: 1}, nil)

    assert slack.me.name == "fake"
    assert slack.team.name == "Foo"
    assert slack.bots     == %{"123" => %{id: "123"}}
    assert slack.channels == %{"123" => %{id: "123"}}
    assert slack.groups   == %{"123" => %{id: "123"}}
    assert slack.users    == %{"123" => %{id: "123"}}

    assert state == 1
  end
end


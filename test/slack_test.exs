defmodule SlackTest do
  use ExUnit.Case

  defmodule Bot do
    use Slack
  end

  test "on_connect returns state by default" do
    assert Bot.handle_connect(nil, 1) == {:ok, 1}
  end

  test "handle_message returns state by default" do
    assert Bot.handle_message(nil, nil, 1) == {:ok, 1}
  end

  test "init formats rtm results properly" do
    rtm = %{
      self: %{name: "fake"},
      team: %{name: "Foo"},
      bots: [%{id: "123"}],
      channels: [%{id: "123"}],
      groups: [%{id: "123"}],
      users: [%{id: "123"}],
      ims: [%{id: "123"}]
    }

    {:ok, %{client: client, state: state}} = Bot.init(%{rtm: rtm, state: 1, client: FakeWebsocketClient, token: "ABC"}, nil)

    assert client.me.name == "fake"
    assert client.team.name == "Foo"
    assert client.bots     == %{"123" => %{id: "123"}}
    assert client.channels == %{"123" => %{id: "123"}}
    assert client.groups   == %{"123" => %{id: "123"}}
    assert client.users    == %{"123" => %{id: "123"}}
    assert client.ims      == %{"123" => %{id: "123"}}

    assert state == 1
  end
end

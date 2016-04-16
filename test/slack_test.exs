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
    result = Slack.send_raw(~s/{"text": "foo"}/, %{socket: nil, client: FakeWebsocketClient})
    assert result == {~s/{"text": "foo"}/, nil}
  end

  test "send_message sends message formatted to client" do
    result = Slack.send_message("hello", "channel", %{socket: nil, client: FakeWebsocketClient})
    assert result == {~s/{"channel":"channel","text":"hello","type":"message"}/, nil}
  end

  test "send_attachments sends message + attachments formatted to client" do
    attachment = %{
      title: "Attachment",
      color: "#fff",
    }
    result = Slack.send_attachments("hello", [attachment], "channel", %{socket: nil, client: FakeWebsocketClient})
    assert result == {~s/{"attachments":[{"color":"#fff","title":"Attachment"}],"channel":"channel","text":"hello","type":"message"}/, nil}
  end

  test "indicate_typing sends typing notification to client" do
    result = Slack.indicate_typing("channel", %{socket: nil, client: FakeWebsocketClient})
    assert result == {~s/{"channel":"channel","type":"typing"}/, nil}
  end

  test "send_ping sends ping to client" do
    result = Slack.send_ping(%{socket: nil, client: FakeWebsocketClient})
    assert result == {~s/{"type":"ping"}/, nil}
  end

  test "send_ping with data sends ping + data to client" do
    result = Slack.send_ping([foo: :bar], %{socket: nil, client: FakeWebsocketClient})
    assert result == {~s/{"foo":"bar","type":"ping"}/, nil}
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

    {:ok, %{slack: slack, state: state}} = Bot.init(%{rtm: rtm, state: 1, client: FakeWebsocketClient}, nil)

    assert slack.me.name == "fake"
    assert slack.team.name == "Foo"
    assert slack.bots     == %{"123" => %{id: "123"}}
    assert slack.channels == %{"123" => %{id: "123"}}
    assert slack.groups   == %{"123" => %{id: "123"}}
    assert slack.users    == %{"123" => %{id: "123"}}

    assert state == 1
  end
end

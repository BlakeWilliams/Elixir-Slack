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

  test "turns @user into a user identifier" do
    slack = %{users: %{"U123" => %{name: "user", id: "U123"}}}
    assert Slack.lookup_user_id("@user", slack) == "U123"
  end

  test "turns @user into direct message identifier, if the channel exists" do
    slack = %{
      users: %{"U123" => %{name: "user", id: "U123"}},
      ims: %{"D789" => %{user: "U123", id: "D789"}}
    }
    assert Slack.lookup_direct_message_id("@user", slack) == "D789"
    assert Slack.lookup_direct_message_id("@missing", slack) == nil
  end

  test "turns a user identifier into direct message identifier, if the channel exists" do
    slack = %{ims: %{"D789" => %{user: "U123", id: "D789"}}}
    assert Slack.lookup_direct_message_id("U123", slack) == "D789"
    assert Slack.lookup_direct_message_id("U000", slack) == nil
  end

  test "turns #channel into a channel identifier" do
    slack = %{channels: %{"C456" => %{name: "channel", id: "C456"}}}
    assert Slack.lookup_channel_id("#channel", slack) == "C456"
  end

  test "turns a user identifier into @user" do
    slack = %{users: %{"U123" => %{name: "user", id: "U123"}}}
    assert Slack.lookup_user_name("U123", slack) == "@user"
  end

  test "turns a direct message identifier into @user" do
    slack = %{
      users: %{"U123" => %{name: "user", id: "U123"}},
      ims: %{"D789" => %{user: "U123", id: "D789"}}
    }
    assert Slack.lookup_user_name("D789", slack) == "@user"
  end

  test "turns a channel identifier into #channel" do
    slack = %{channels: %{"C456" => %{name: "channel", id: "C456"}}}
    assert Slack.lookup_channel_name("C456", slack) == "#channel"
  end

  test "send_raw sends slack formatted to client" do
    result = Slack.send_raw(~s/{"text": "foo"}/, %{socket: nil, client: FakeWebsocketClient})
    assert result == {~s/{"text": "foo"}/, nil}
  end

  test "send_message sends message formatted to client" do
    result = Slack.send_message("hello", "channel", %{socket: nil, client: FakeWebsocketClient})
    assert result == {~s/{"channel":"channel","text":"hello","type":"message"}/, nil}
  end

  test "send_message understands #channel names" do
    slack = %{
      socket: nil,
      client: FakeWebsocketClient,
      channels: %{"C456" => %{name: "channel", id: "C456"}}
    }
    result = Slack.send_message("hello", "#channel", slack)
    assert result == {~s/{"channel":"C456","text":"hello","type":"message"}/, nil}
  end

  test "send_message understands @user names" do
    slack = %{
      socket: nil,
      client: FakeWebsocketClient,
      users: %{"U123" => %{name: "user", id: "U123"}},
      ims: %{"D789" => %{user: "U123", id: "D789"}}
    }
    result = Slack.send_message("hello", "@user", slack)
    assert result == {~s/{"channel":"D789","text":"hello","type":"message"}/, nil}
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
      ims: [%{id: "123"}]
    }

    {:ok, %{slack: slack, state: state}} = Bot.init(%{rtm: rtm, state: 1, client: FakeWebsocketClient, token: "ABC"}, nil)

    assert slack.me.name == "fake"
    assert slack.team.name == "Foo"
    assert slack.bots     == %{"123" => %{id: "123"}}
    assert slack.channels == %{"123" => %{id: "123"}}
    assert slack.groups   == %{"123" => %{id: "123"}}
    assert slack.users    == %{"123" => %{id: "123"}}
    assert slack.ims      == %{"123" => %{id: "123"}}

    assert state == 1
  end
end

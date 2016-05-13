defmodule Slack.SendsTest do
  use ExUnit.Case
  alias Slack.Sends
  alias Slack.State

  defmodule FakeWebsocketState do
    def send({:text, json}, socket) do
      {json, socket}
    end
  end

  test "send_raw sends slack formatted to client" do
    slack = %State{
      socket: nil,
      client: FakeWebsocketState
    }
    result = Sends.send_raw(~s/{"text": "foo"}/, slack)
    assert result == {~s/{"text": "foo"}/, nil}
  end

  test "send_message sends message formatted to client" do
    slack = %State{
      socket: nil,
      client: FakeWebsocketState
    }
    result = Sends.send_message("hello", "channel", slack)
    assert result == {~s/{"channel":"channel","text":"hello","type":"message"}/, nil}
  end

  test "send_message understands #channel names" do
    slack = %State{
      socket: nil,
      client: FakeWebsocketState,
      channels: %{"C456" => %{name: "channel", id: "C456"}}
    }
    result = Sends.send_message("hello", "#channel", slack)
    assert result == {~s/{"channel":"C456","text":"hello","type":"message"}/, nil}
  end

  test "send_message understands @user names" do
    slack = %State{
      socket: nil,
      client: FakeWebsocketState,
      users: %{"U123" => %{name: "user", id: "U123"}},
      ims: %{"D789" => %{user: "U123", id: "D789"}}
    }
    result = Sends.send_message("hello", "@user", slack)
    assert result == {~s/{"channel":"D789","text":"hello","type":"message"}/, nil}
  end

  test "indicate_typing sends typing notification to client" do
    slack = %State{
      socket: nil,
      client: FakeWebsocketState
    }
    result = Sends.indicate_typing("channel", slack)
    assert result == {~s/{"channel":"channel","type":"typing"}/, nil}
  end

  test "send_ping sends ping to client" do
    slack = %State{
      socket: nil,
      client: FakeWebsocketState
    }
    result = Sends.send_ping(slack)
    assert result == {~s/{"type":"ping"}/, nil}
  end

  test "send_ping with data sends ping + data to client" do
    slack = %State{
      socket: nil,
      client: FakeWebsocketState
    }
    result = Sends.send_ping([foo: :bar], slack)
    assert result == {~s/{"foo":"bar","type":"ping"}/, nil}
  end
end

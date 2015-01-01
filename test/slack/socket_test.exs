defmodule Slack.SocketTest do
  use ExUnit.Case

  test "it calls the handler with proper type" do
    message = ~s/{"type": "presence_change", "presence": "away"}/
    state = %{
      module: __MODULE__.FakeHandler,
      module_state: [],
      slack_state: %Slack.State{}
    }

    {:ok, result} = Slack.Socket.websocket_handle({:text, message}, "foo", state)

    assert result.handler_state == ["bar"]
  end

  test "it returns existing state if called without type" do
    message = ~s/{"presence": "away"}/
    state = %{
      module: __MODULE__.FakeHandler,
      module_state: [1],
      slack_state: %Slack.State{}
    }

    {:ok, result} = Slack.Socket.websocket_handle({:text, message}, "foo", state)

    assert result.module_state == [1]
  end

  test "it responds to pings with pong" do
    state = []
    assert {:reply, {:pong, "cookie!"}, ^state} =
      Slack.Socket.websocket_handle({:ping, "cookie!"}, "foo", state)
  end

  defmodule FakeHandler do
    def handle_message({:type, "presence_change", _message}, socket_state, state) do
      ^socket_state = %Slack.State{}

      new_state = state ++ ["bar"]
      {:ok, new_state}
    end
  end
end

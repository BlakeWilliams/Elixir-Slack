defmodule Slack.SocketTest do
  use ExUnit.Case

  test "it calls the handler with proper type" do
    message = ~s/{"type": "presence_change", "presence": "away"}/
    state = %{handler: FakeHandler, handler_state: []}

    assert {:ok, ^state} =
      Slack.Socket.websocket_handle({:text, message}, "foo", state)
  end

  test "it responds to pings with pong" do
    state = []
    assert {:reply, {:pong, "cookie!"}, ^state} =
      Slack.Socket.websocket_handle({:ping, "cookie!"}, "foo", state)
  end
end

defmodule FakeWebsocket do
  def start_link(token, _module, _options) do
    IO.write "socket:#{token}"
    {:ok, nil}
  end
end

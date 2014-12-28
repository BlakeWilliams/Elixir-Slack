ExUnit.start()

defmodule FakeHandler do
  use Slack

  def handle_message({:type, "presence_change", _message}, _socket, state) do
    {:ok, state}
  end
end

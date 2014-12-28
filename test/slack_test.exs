defmodule SlackTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "start_link calls websocket with rtm token result" do
    assert capture_io(fn ->
      Slack.start_link(__MODULE__, "abc123", FakeRtm, FakeWebsocket)
    end) == "rtm:abc123socket:abc123"
  end
end

defmodule FakeRtm do
  def start(token) do
    IO.write "rtm:#{token}"
    {:ok, %{url: token}}
  end
end

defmodule FakeHandler do
  use Slack

  def handle_message({:type, "presence_change", _message}, _socket, state) do
    {:ok, state}
  end
end

defmodule SlackTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "send sends a :text message to the websocket" do
    assert capture_io(fn ->
      Slack.send_message("Hi!", "123", [], FakeSocket)
    end) == ~s/{"channel":"123","text":"Hi!","type":"message"}/
  end

  test "start_link calls websocket with rtm token result" do
    assert capture_io(fn ->
      Slack.start_link(__MODULE__, "abc123", FakeRtm, FakeWebsocket)
    end) == "rtm:abc123socket:abc123"
  end
end

defmodule FakeSocket do
  def send(message, _socket) do
    {:text, message} = message
    IO.write message
  end
end

defmodule FakeRtm do
  def start(token) do
    IO.write "rtm:#{token}"
    {:ok, %{url: token}}
  end
end

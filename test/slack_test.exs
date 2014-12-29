defmodule SlackTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "send sends a :text message to the websocket" do
    assert capture_io(fn ->
      Slack.send_message("Hi!", "123", [], FakeWebsocket)
    end) == ~s/{"channel":"123","text":"Hi!","type":"message"}/
  end

  test "start_link calls websocket with rtm token result" do
    options = %{rtm: FakeRtm, websocket: FakeWebsocket}

    {:ok, "foo"} = Slack.start_link(__MODULE__, "abc123", "foo", options)
  end
end

defmodule FakeRtm do
  def start(token) do
    {:ok, %{url: token}}
  end
end

defmodule FakeWebsocket do
  def start_link(token, _module, options) do
    {:ok, options.state}
  end

  def send(message, _socket) do
    {:text, message} = message
    IO.write message
  end
end

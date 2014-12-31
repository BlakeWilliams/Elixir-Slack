defmodule SlackTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "send sends a :text message to the websocket" do
    fake_state = %{socket: []}
    assert capture_io(fn ->
      Slack.send_message("Hi!", "123", fake_state, __MODULE__.FakeWebsocket)
    end) == ~s/{"channel":"123","text":"Hi!","type":"message"}/
  end

  test "start_link calls websocket with rtm token result" do
    options = %{rtm: __MODULE__.FakeRtm, websocket: __MODULE__.FakeWebsocket}

    {:ok, "foo"} = Slack.start_link(__MODULE__, "abc123", "foo", options)
  end


  defmodule FakeRtm do
    def start(token) do
      {:ok, %{url: token, channels: [%{id: "1"}], users: [%{id: "2"}]}}
    end
  end

  defmodule FakeWebsocket do
    def start_link(token, _module, options) do
      channels = options.channels 
      ^channels = [%{id: "1"}]

      users = options.users
      ^users = [%{id: "2"}]

      {:ok, options.state}
    end

    def send(message, socket) do
      ^socket = []

      {:text, message} = message
      IO.write message
    end
  end
end

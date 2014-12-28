# Elixir-Slack

This is a work in progress Slack [Real Time Messaging API] client for Elixir.

[Real time Messaging API]: https://api.slack.com/rtm

## Usage

Add Slack to your `mix.exs` dependencies.

```elixir
def deps do
  [{:slack, git: "https://github.com/BlakeWilliams/Elixir-Slack"}]
end
```

Define a module that uses the Slack behaviour and defines the appropriate
callback methods.

```elixir
defmodule SlackRtm do
  use Slack

  def start_link() do
    Slack.start_link(__MODULE__, "token_value")
  end

  def init(_socket) do
    {:ok, []}
  end

  def handle_message({:type, "message", response}, socket, state) do
    state = state ++ [response.text]
    {:ok, state}
  end

  def handle_message({:type, type, _response}, _socket, state) do
    {:ok, state}
  end
end
```

At the moment there's no method to send replies without using
`:websocket_client.send`. You can reply to the server via
`:websocket_client.send({:text, "Hello!"}, socket)`.

Slack has *a lot* of message types so it's a good idea to define a callback like
above where unhandled message types don't crash your application. You can find a
list of message types and examples on the [RTM API page].

[RTM API page]: https://api.slack.com/rtm

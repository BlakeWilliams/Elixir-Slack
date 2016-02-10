[![Build
Status](https://api.travis-ci.org/BlakeWilliams/Elixir-Slack.svg?branch=master)](https://travis-ci.org/BlakeWilliams/Elixir-Slack)

# Elixir-Slack

This is a work in progress Slack [Real Time Messaging API] client for Elixir.
You'll need a Slack API token which can be retrieved from the [Web API page] or
by creating a new [bot integration].

[Real time Messaging API]: https://api.slack.com/rtm
[Web API page]: https://api.slack.com/web
[bot integration]: https://my.slack.com/services/new/bot

## Usage

Add Slack to your `mix.exs` `application` and `dependencies` methods. You'll
also need [websocket_client] since hex.pm doesn't install git based
dependencies.

[websocket_client]: https://github.com/jeremyong/websocket_client

```elixir
def application do
  [applications: [:logger, :slack]]
end

def deps do
  [{:slack, "~> 0.4.2"},
   {:websocket_client, git: "https://github.com/jeremyong/websocket_client"}]
end
```

Define a module that uses the Slack behaviour and defines the appropriate
callback methods.

```elixir
defmodule SlackRtm do
  use Slack

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_message(message = %{type: "message"}, slack, state) do
    message_to_send = "Received #{length(state)} messages so far!"
    send_message(message_to_send, message.channel, slack)

    {:ok, state ++ [message.text]}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end
end
```

To run this example, you'll also want to call `SlackRtm.start_link("token", [])`
and run the project with `mix run --no-halt`.

You can send messages to channels using `send_message/3` which takes the message
as the first argument, channel as the second, and the passed in `slack` state
as the third.

The passed in `slack` state holds the current user properties as `me`, team
properties as `team`, the current websocket connection as `socket`, and a list
of  `bots`, `channels`, `groups`, and `users`.

[rtm.start]: https://api.slack.com/methods/rtm.start

Slack has *a lot* of message types so it's a good idea to define a callback like
above where unhandled message types don't crash your application. You can find a
list of message types and examples on the [RTM API page].

You can find more detailed documentation on the [Slack hexdocs page].

[RTM API page]: https://api.slack.com/rtm
[Slack hexdocs page]: http://hexdocs.pm/slack/

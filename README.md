[![Build
Status](https://api.travis-ci.org/BlakeWilliams/Elixir-Slack.svg?branch=master)](https://travis-ci.org/BlakeWilliams/Elixir-Slack)

# Elixir-Slack

This is a Slack [Real Time Messaging API] client for Elixir.  You'll need a
Slack API token which can be retrieved from the [Web API page] or by creating a
new [bot integration].

[Real time Messaging API]: https://api.slack.com/rtm
[Web API page]: https://api.slack.com/web
[bot integration]: https://my.slack.com/services/new/bot

## Installing

Add Slack to your `mix.exs` `application` and `dependencies` functions.

[websocket_client]: https://github.com/jeremyong/websocket_client

```elixir
def application do
  [applications: [:logger, :slack]]
end

def deps do
  [{:slack, "~> 0.10.0"}]
end
```

## RTM (Bot) Usage

Define a module that uses the Slack behaviour and defines the appropriate
callback methods.

```elixir
defmodule SlackRtm do
  use Slack

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    send_message("I got a message!", message.channel, slack)
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    IO.puts "Sending your message, captain!"

    send_message(text, channel, slack)

    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}
end
```

To run this example, you'll want to call `Slack.Bot.start_link(SlackRtm, [],
"TOKEN_HERE")` and run the project with `mix run --no-halt`.

You can send messages to channels using `send_message/3` which takes the message
as the first argument, channel/user as the second, and the passed in `slack`
state as the third.

The passed in `slack` state holds the current user properties as `me`, team
properties as `team`, the current websocket connection as `socket`, and a list
of  `bots`, `channels`, `groups`, `users`, and `ims` (direct message channels).

[rtm.start]: https://api.slack.com/methods/rtm.start

If you want to do things like trigger the sending of messages outside of your
Slack handlers, you can leverage the `handle_info/3` callback to implement an
external API.

This allows you to both respond to Slack RTM events and programmatically control
your bot from external events.

```elixir
{:ok, rtm} = Slack.Bot.start_link(SlackRtm, [], "token")
send rtm, {:message, "External message", "#general"}
#=> {:message, "External message", "#general"}
#==> Sending your message, captain!
```

Slack has *a lot* of message types so it's a good idea to define a callback like
above where unhandled message types don't crash your application. You can find a
list of message types and examples on the [RTM API page].

You can find more detailed documentation on the [Slack hexdocs
page][documentation].

[RTM API page]: https://api.slack.com/rtm

## Web API Usage

The complete Slack Web API is implemented by generating modules/functions from
the JSON documentation. You can view this project's [documentation] for more
details.

There are two ways to authenticate your API calls. You can configure `api_token`
on `slack` that will authenticate all calls to the API automatically.

```elixir
config :slack, api_token: "VALUE"
```

Alternatively you can pass in `%{token: "VALUE"}` to any API call in
`optional_params`. This also allows you to override the configured `api_token`
value if desired.

Quick example, getting the names of everyone on your team:

```elixir
names = Slack.Web.Users.list(%{token: "TOKEN_HERE"})
|> Map.get("members")
|> Enum.map(fn(member) ->
  member["real_name"]
end)
```

[documentation]: http://hexdocs.pm/slack/

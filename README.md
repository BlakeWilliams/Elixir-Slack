[![Build
Status](https://api.travis-ci.org/BlakeWilliams/Elixir-Slack.svg?branch=master)](https://travis-ci.org/BlakeWilliams/Elixir-Slack)

# Elixir-Slack

This is a Slack [Real Time Messaging API] client for Elixir.  You'll need a
Slack API token which can be retrieved by following the [Token Generation
Instructions] or by creating a
new [bot integration].

[Real time Messaging API]: https://api.slack.com/rtm
[Token Generation Instructions]: https://hexdocs.pm/slack/token_generation_instructions.html
[bot integration]: https://my.slack.com/services/new/bot

## Installing

Add Slack to your `mix.exs` `dependencies` function.

[websocket_client]: https://github.com/jeremyong/websocket_client

```elixir
def application do
  [extra_applications: [:logger]]
end

def deps do
  [{:slack, "~> 1.0.0"}]
end
```

## Upgrading from 0.x to 1.0

The newest version of the Slack client introduces breaking changes with regards to starting and connecting to the Real Time Messaging API. `rtm.start` is now [deprecated](https://api.slack.com/methods/rtm.start) and has since been replaced with [`rtm.connect`](https://api.slack.com/methods/rtm.connect). **This has removed the list of  `bots`, `channels`, `groups`, `users`, and `ims` that are normally returned from `rtm.start`**. Additionally, these lists are now rate-limited. In order to achieve relative parity to the old way of doing things, you'll need to make one change in your code:

### Make additional calls to the Slack API fo grab bots, channels, groups, users, and IMs

Wherever you grab the passed in `slack` state, add in additional calls to populate these lists:

```elixir
slack
|> Map.put(:bots, Slack.Web.Bots.info(%{token: token}) |> Map.get("bot"))
|> Map.put(:channels, Slack.Web.Channels.list(%{token: token}) |> Map.get("channels"))
|> Map.put(:groups, Slack.Web.Groups.list(%{token: token}) |> Map.get("groups"))
|> Map.put(:ims, Slack.Web.Im.list(%{token: token}) |> Map.get("ims"))
|> Map.put(:users, Slack.Web.Users.list(%{token: token}) |> Map.get("members"))
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
properties as `team`, and the current websocket connection as `socket`.

[rtm.connect]: https://api.slack.com/methods/rtm.connect

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

### Web Client Configuration

A custom client callback module can be configured for cases in which you need extra control
over how calls to the web API are performed. This can be used to control timeouts, or to add additional
custom error handling as needed.

```elixir
config :slack, :web_http_client, YourApp.CustomClient
```

All Web API calls from documentation-generated modules/functions will call `post!/2` with the generated url
and body passed as arguments.

In the case where you only need to control the options passed to HTTPoison/hackney, the default client accepts
a keyword list as an additional configuration parameter. Note that this is ignored if configuring a custom client.

See [HTTPoison docs](https://hexdocs.pm/httpoison/HTTPoison.html#request/5) for a list of available options.

```elixir
config :slack, :web_http_client_opts, [timeout: 10_000, recv_timeout: 10_000]
```

## Testing

For integration tests, you can change the default Slack URL to your fake Slack
server:

```elixir
config :slack, url: "http://localhost:8000"
```

[documentation]: http://hexdocs.pm/slack/

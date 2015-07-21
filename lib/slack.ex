defmodule Slack do
  @moduledoc """
  Slack is a genserver-ish interface for working with the Slack real time
  messaging API through a Websocket connection.

  To use this module you'll need a valid Slack API token. You can find your
  personal token on the [Slack Web API] page, or you can add a new
  [bot integration].

  [Slack Web API]: https://api.slack.com/web
  [bot integration]: https://api.slack.com/bot-users

  ## Example

  ```
  defmodule Bot do
    use Slack

    def handle_message(message = {type: "message"}, slack, state) do
      if message.text == "Hi" do
        send_message("Hi has been said #\{state} times", message.channel, slack)
        state = state + 1
      end

      {:ok, state}
    end
  end

  Bot.start_link("API_TOKEN", 1)
  ```

  `handle_*` methods are always passed `slack` and `state` arguments. The
  `slack` argument holds the state of Slack and is kept up to date
  automatically.

  In this example we're just matching against the message type and checking if
  the text content is "Hi" and if so, we reply with how many times "Hi" has been
  said.

  The message type is pattern matched against because the
  [Slack RTM API](https://api.slack.com/rtm) defines many different types of
  messages that we can receive. Because of this it's wise to write a catch-all
  `handle_message/3` in your bots to prevent crashing.

  ## Callbacks

  * `handle_connect(slack, state)` - called when connected to Slack.
  * `handle_message(message, slack, state)` - called when a message is received.
  * `handle_close(reason, slack, state)` - called when websocket is closed.

  ## Slack argument

  The Slack argument that's passed to each callback is what contains all of the
  state related to Slack including a list of channels, users, groups, bots, and
  even the socket.

  Here's a list of what's stored:

  * me - The current bot/users information stored as a map of properties.
  * team - The current team's information stored as a map of properties.
  * bots - Stored as a map with id's as keys.
  * channels - Stored as a map with id's as keys.
  * groups - Stored as a map with id's as keys.
  * users - Stored as a map with id's as keys.
  * socket - The connection to Slack.

  For all but `socket`, you can see what types of data to expect each of the
  types to contain from the [Slack API types] page.

  [Slack API types]: https://api.slack.com/types
  """
  defmacro __using__(_) do
    quote do
      @behaviour :websocket_client_handler
      import Slack
      import Slack.Handlers

      def start_link(token, initial_state) do
        {:ok, rtm} = Slack.Rtm.start(token)

        state = %{rtm: rtm, state: initial_state}

        url = String.to_char_list(rtm.url)
        :websocket_client.start_link(url, __MODULE__, state)
      end

      def init(%{rtm: rtm, state: state}, socket) do
        slack = %{
          socket: socket,
          me: rtm.self,
          team: rtm.team,
          bots: rtm_list_to_map(rtm.bots),
          channels: rtm_list_to_map(rtm.channels),
          groups: rtm_list_to_map(rtm.groups),
          users: rtm_list_to_map(rtm.users),
        }

        {:ok, state} = handle_connect(slack, state)
        {:ok, %{slack: slack, state: state}}
      end

      def websocket_info(:start, _connection, state) do
        {:ok, state}
      end

      def websocket_terminate(reason, _connection, %{slack: slack, state: state}) do
        handle_close(reason, slack, state)
      end

      def websocket_handle({:ping, data}, _connection, state) do
        {:reply, {:pong, data}, state}
      end

      def websocket_handle({:text, message}, _con, %{slack: slack, state: state}) do
        message = JSX.decode!(message, [{:labels, :atom}])
        if Map.has_key?(message, :type) do
          {:ok, state} = handle_message(message, slack, state)
          {:ok, slack} = handle_slack(message, slack)
        end

        {:ok, %{slack: slack, state: state}}
      end

      defp rtm_list_to_map(list) do
        Enum.reduce(list, %{}, fn (item, map) ->
          Map.put(map, item.id, item)
        end)
      end

      def handle_connect(_slack, state), do: {:ok, state}
      def handle_message(_message, _slack, state), do: {:ok, state}
      def handle_close(_reason, _slack, state), do: {:error, state}

      defoverridable [handle_connect: 2, handle_message: 3, handle_close: 3]
    end
  end

  def send_message(text, channel, slack) do
    message = JSX.encode!(%{
      type: "message",
      text: text,
      channel: channel
    })

    send_raw(message, slack)
  end

  def send_raw(json, %{socket: socket}, client \\ :websocket_client) do
    client.send({:text, json}, socket)
  end
end

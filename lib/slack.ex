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

    def handle_message(message = %{type: "message"}, slack) do
      if message.text == "Hi" do
        send_message("Hello to you too!", message.channel, slack)
      end
    end
  end

  Bot.start_link("API_TOKEN")
  ```

  `handle_*` methods are always passed `slack` and `state` arguments. The
  `slack` argument holds the state of Slack and is kept up to date
  automatically.

  In this example we're just matching against the message type and checking if
  the text content is "Hi" and if so, we reply with our own greeting.

  The message type is pattern matched against because the
  [Slack RTM API](https://api.slack.com/rtm) defines many different types of
  messages that we can receive. Because of this it's wise to write a catch-all
  `handle_message/3` in your bots to prevent crashing.

  ## Callbacks

  * `handle_connect(slack)` - called when connected to Slack.
  * `handle_message(message, slack)` - called when a message is received.
  * `handle_close(reason, slack)` - called when websocket is closed.
  * `handle_info(message, slack)` - called when any other message is received in the process mailbox.

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
  * ims (direct message channels) - Stored as a map with id's as keys.
  * socket - The connection to Slack.
  * client - The client that makes calls to Slack.

  For all but `socket` and `client`, you can see what types of data to expect each of the
  types to contain from the [Slack API types] page.

  [Slack API types]: https://api.slack.com/types
  """

  defmacro __using__(_) do
    quote do
      @behaviour :websocket_client_handler
      require Logger
      import Slack
      import Slack.Lookups
      import Slack.Sends

      def start_link(token, client \\ :websocket_client) do
        case Slack.Rtm.start(token) do
          {:ok, rtm} ->
            state = %{
              rtm: rtm,
              client: client,
              token: token
            }
            url = String.to_char_list(rtm.url)
            client.start_link(url, __MODULE__, state)
          {:error, %HTTPoison.Error{reason: :connect_timeout}} ->
            {:error, "Timed out while connecting to the Slack RTM API"}
          {:error, %HTTPoison.Error{reason: :nxdomain}} ->
            {:error, "Could not connect to the Slack RTM API"}
          {:error, error} ->
            {:error, error}
        end
      end

      def init(%{rtm: rtm, client: client, token: token}, socket) do
        slack = %Slack.State{
          socket: socket,
          client: client,
          token: token,
          me: rtm.self,
          team: rtm.team,
          bots: rtm_list_to_map(rtm.bots),
          channels: rtm_list_to_map(rtm.channels),
          groups: rtm_list_to_map(rtm.groups),
          users: rtm_list_to_map(rtm.users),
          ims: rtm_list_to_map(rtm.ims)
        }

        handle_connect(slack)
        {:ok, slack}
      end

      def websocket_info(:start, _connection, state) do
        {:ok, state}
      end

      def websocket_info(message, _connection, slack) do
        try do
          handle_info(message, slack)
        rescue
          e -> handle_exception(e)
        end

        {:ok, slack}
      end

      def websocket_terminate(reason, _conn, slack) do
        try do
          handle_close(reason, slack)
        rescue
          e -> handle_exception(e)
        end
      end

      def websocket_handle({:ping, data}, _conn, state) do
        {:reply, {:pong, data}, state}
      end

      def websocket_handle({:text, message}, _conn, slack) do
        message = prepare_message message

        slack = if Map.has_key?(message, :type) do
          try do
            handle_message(message, slack)
            slack
          rescue
            e -> handle_exception(e)
          end

          Slack.State.update(message, slack)
        else
          slack
        end

        {:ok, slack}
      end

      defp rtm_list_to_map(list) do
        Enum.reduce(list, %{}, fn (item, map) ->
          Map.put(map, item.id, item)
        end)
      end

      defp prepare_message(binstring) do
        binstring
          |> :binary.split(<<0>>)
          |> List.first
          |> JSX.decode!([{:labels, :atom}])
      end

      defp handle_exception(e) do
        message = Exception.message(e)
        Logger.error(message)
        System.stacktrace |> Exception.format_stacktrace |> Logger.error
        raise message
      end

      def handle_connect(_slack ), do: :ok
      def handle_message(_message, _slack), do: :ok
      def handle_close(_reason, _slack), do: :ok
      def handle_info(_message, _slack), do: :ok

      defoverridable [handle_connect: 1, handle_message: 2, handle_close: 2, handle_info: 2]
    end
  end
end

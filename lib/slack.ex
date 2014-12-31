defmodule Slack do
  @moduledoc """
  A behaviour module for implementing Slack realt time messaging through a
  websocket connection.

  To use this module you will need a valid Slack API token. You can find your
  token on the [Slack Web API] page.

  [Slack Web API]: https://api.slack.com/web

  ## Example

  ```
  defmodule SlackRtm do
    use Slack

    def start_link(initial_state) do
      Slack.start_link(__MODULE__, "token_value", initial_state)
    end

    def init(state, _slack) do
      {:ok, state}
    end

    def handle_message({:type, "message", response}, slack, state) do
      Slack.send_message("Received message!", response.channel, slack)
      state = state ++ [response.text]
      {:ok, state}
    end

    def handle_message({:type, type, _response}, _slack, state) do
      IO.puts "No callback for #\{type}"
      {:ok, state}
    end
  end
  ```

  Slack has a large variety of types it can send you, so it's wise ot have a
  catch all handle like above to avoid crashing.

  ## Callbacks

  * `init(state, slack_state)` - Called when the websocket connection starts


    It must return:


      - `{:ok, state}`

  * `handle_message({:type, type, json_map}, slack_state, state)`

    It must return:

      - `{:ok, state}`

  You can find every type Slack will respond with and examples of each on
  the [Slack RTM API](https://api.slack.com/rtm) page.
  """

  defmacro __using__(_) do
    quote do
      @behaviour Slack.Handler

      def init(state, slack) do
        {:ok, state}
      end

      def handle_message({:type, type, _response}, _slack, state) do
        {:stop, {:unhandled_type, type}, state}
      end

      defoverridable [init: 2, handle_message: 3]
    end
  end

  @doc """
  Starts a websocket connection to the Slack real time messaging API using the
  given token.

  Once started it calls the `init/1` function on the given module passing in the
  websocket connection as its argument.
  """
  def start_link(module, token, state, options \\ %{}) do
    options = Map.merge(default_options, options)
    websocket = options.websocket

    {:ok, rtm_response} = options.rtm.start(token)

    url = rtm_response.url |> String.to_char_list

    bootstrap_state = %{
      handler: module,
      state: state,
      channels: rtm_response.channels,
      users: rtm_response.users,
    }

    websocket.start_link(
      url,
      Slack.Socket,
      bootstrap_state
    )
  end

  @doc """
  Sends `text` as a message to the the channel with id of `channel_id`

  eg: `Slack.send_message("Morning everyone!", "CA1B2C3D4", sock)`
  """
  def send_message(text, channel_id, state, websocket \\ :websocket_client) do
    socket = state.socket
    message = %{type: "message", text: text, channel: channel_id}
              |> JSX.encode!

    websocket.send({:text, message}, socket)
  end

  defp default_options do
    %{
      rtm: Slack.Rtm,
      websocket: :websocket_client
    }
  end
end

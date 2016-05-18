defmodule Slack.Sends do
  alias Slack.Lookups

  @doc """
  Sends `text` to `channel` for the given `client` connection.  `channel` can be
  a string in the format of `"#CHANNEL_NAME"`, `"@USER_NAME"`, or any ID that
  Slack understands.
  """
  def send_message(text, channel = "#" <> channel_name, client) do
    channel_id = Lookups.lookup_channel_id(channel, client)

    if channel_id do
      send_message(text, channel_id, client)
    else
      raise ArgumentError, "channel ##{channel_name} not found"
    end
  end
  def send_message(text, user = "@" <> _user_name, client) do
    direct_message_id = Lookups.lookup_direct_message_id(user, client)

    if direct_message_id do
      send_message(text, direct_message_id, client)
    else
      open_im_channel(
        client.token,
        Lookups.lookup_user_id(user, client),
        fn id -> send_message(text, id, client) end,
        fn _reason -> :delivery_failed end
      )
    end
  end
  def send_message(text, channel, client) do
    %{
      type: "message",
      text: text,
      channel: channel
    }
      |> JSX.encode!
      |> send_raw(client)
  end

  @doc """
  Notifies Slack that the current user is typing in `channel`.
  """
  def indicate_typing(channel, client) do
    %{
      type: "typing",
      channel: channel
    }
      |> JSX.encode!
      |> send_raw(client)
  end

  @doc """
  Sends Slack a ping message with optional `payload`.
  """
  def send_ping(payload \\ [], client) do
    %{
      type: "ping"
    }
      |> Dict.merge(payload)
      |> JSX.encode!
      |> send_raw(client)
  end

  @doc """
  Sends raw JSON to a given socket.
  """
  def send_raw(json, %{socket: socket, client: client}) do
    client.send({:text, json}, socket)
  end

  defp open_im_channel(token, user_id, on_success, on_error) do
    im_open = HTTPoison.post(
      "https://slack.com/api/im.open",
      {:form, [token: token, user: user_id]}
    )
    case im_open do
      {:ok, response} ->
        case JSX.decode!(response.body, [{:labels, :atom}]) do
          %{ok: true, channel: %{id: id}} -> on_success.(id)
          _ -> on_error.()
        end
      {:error, reason} -> on_error.(reason)
    end
  end
end

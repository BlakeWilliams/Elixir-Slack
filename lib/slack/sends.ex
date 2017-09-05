defmodule Slack.Sends do
  @moduledoc "Utility functions for sending slack messages"
  alias Slack.Lookups

  @doc """
  Sends `text` to `channel` for the given `slack` connection.  `channel` can be
  a string in the format of `"#CHANNEL_NAME"`, `"@USER_NAME"`, or any ID that
  Slack understands.
  """
  def send_message(text, channel = "#" <> channel_name, slack) do
    channel_id = Lookups.lookup_channel_id(channel, slack)

    if channel_id do
      send_message(text, channel_id, slack)
    else
      raise ArgumentError, "channel ##{channel_name} not found"
    end
  end
  def send_message(text, user_id = "U" <> _user_id, slack) do
    user_name = Slack.Lookups.lookup_user_name(user_id, slack)
    send_message(text, user_name, slack)
  end
  def send_message(text, user = "@" <> _user_name, slack) do
    direct_message_id = Lookups.lookup_direct_message_id(user, slack)

    if direct_message_id do
      send_message(text, direct_message_id, slack)
    else
      open_im_channel(
        slack.token,
        Lookups.lookup_user_id(user, slack),
        fn id -> send_message(text, id, slack) end,
        fn _reason -> :delivery_failed end
      )
    end
  end
  def send_message(text, channel, slack) do
    %{
      type: "message",
      text: text,
      channel: channel
    }
      |> Poison.encode!()
      |> send_raw(slack)
  end

  @doc """
  Notifies Slack that the current user is typing in `channel`.
  """
  def indicate_typing(channel, slack) do
    %{
      type: "typing",
      channel: channel
    }
      |> Poison.encode!()
      |> send_raw(slack)
  end

  @doc """
  Notifies slack that the current `slack` user is typing in `channel`.
  """
  def send_ping(data \\ %{}, slack) do
    %{
      type: "ping"
    }
      |> Map.merge(Map.new(data))
      |> Poison.encode!()
      |> send_raw(slack)
  end

  @doc """
  Sends raw JSON to a given socket.
  """
  def send_raw(json, %{process: pid, client: client}) do
    client.cast(pid, {:text, json})
  end

  defp open_im_channel(token, user_id, on_success, on_error) do
    url = Application.get_env(:slack, :url, "https://slack.com")

    im_open = HTTPoison.post(
      url <> "/api/im.open",
      {:form, [token: token, user: user_id]}
    )
    case im_open do
      {:ok, response} ->
        case Poison.Parser.parse!(response.body, keys: :atoms) do
          %{ok: true, channel: %{id: id}} -> on_success.(id)
          _ -> on_error.()
        end
      {:error, reason} -> on_error.(reason)
    end
  end
end

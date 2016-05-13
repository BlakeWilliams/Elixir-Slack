defmodule Slack.Lookups do
  
  alias Slack.Client
  
  @doc ~S"""
  Turns a string like `"@USER_NAME"` into the ID that Slack understands (`"U…"`).
  """
  def lookup_user_id("@" <> user_name, client) do
    client.users
    |> Map.values
    |> Enum.find(%{ }, fn user -> user.name == user_name end)
    |> Map.get(:id)
  end

  @doc ~S"""
  Turns a string like `"@USER_NAME"` or a user ID (`"U…"`) into the ID for the
  direct message channel of that user (`"D…"`).  `nil` is returned if a direct
  message channel has not yet been opened.
  """
  def lookup_direct_message_id(user = "@" <> _user_name, client) do
    user
    |> lookup_user_id(client)
    |> lookup_direct_message_id(client)
  end
  def lookup_direct_message_id(user_id, client) do
    client.ims
    |> Map.values
    |> Enum.find(%{ }, fn direct_message -> direct_message.user == user_id end)
    |> Map.get(:id)
  end

  @doc ~S"""
  Turns a string like `"@CHANNEL_NAME"` into the ID that Slack understands
  (`"C…"`).
  """
  def lookup_channel_id("#" <> channel_name, client) do
    client.channels
    |> Map.values
    |> Enum.find(fn channel -> channel.name == channel_name end)
    |> Map.get(:id)
  end

  @doc ~S"""
  Turns a Slack user ID (`"U…"`) or direct message ID (`"D…"`) into a string in
  the format "@USER_NAME".
  """
  def lookup_user_name(direct_message_id = "D" <> _id, client) do
    lookup_user_name(client.ims[direct_message_id].user, client)
  end
  def lookup_user_name(user_id = "U" <> _id, client) do
    "@" <> client.users[user_id].name
  end

  @doc ~S"""
  Turns a Slack channel ID (`"C…"`) into a string in the format "#CHANNEL_NAME".
  """
  def lookup_channel_name(channel_id = "C" <> _id, client) do
    "#" <> client.channels[channel_id].name
  end
end

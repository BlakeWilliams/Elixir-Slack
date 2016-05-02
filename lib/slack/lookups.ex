defmodule Slack.Lookups do
  @doc ~S"""
  Turns a string like `"@USER_NAME"` into the ID that Slack understands (`"U…"`).
  """
  def lookup_user_id("@" <> user_name, slack) do
    slack.users
    |> Map.values
    |> Enum.find(%{ }, fn user -> user.name == user_name end)
    |> Map.get(:id)
  end

  @doc ~S"""
  Turns a string like `"@USER_NAME"` or a user ID (`"U…"`) into the ID for the
  direct message channel of that user (`"D…"`).  `nil` is returned if a direct
  message channel has not yet been opened.
  """
  def lookup_direct_message_id(user = "@" <> _user_name, slack) do
    user
    |> lookup_user_id(slack)
    |> lookup_direct_message_id(slack)
  end
  def lookup_direct_message_id(user_id, slack) do
    slack.ims
    |> Map.values
    |> Enum.find(%{ }, fn direct_message -> direct_message.user == user_id end)
    |> Map.get(:id)
  end

  @doc ~S"""
  Turns a string like `"@CHANNEL_NAME"` into the ID that Slack understands
  (`"C…"`).
  """
  def lookup_channel_id("#" <> channel_name, slack) do
    slack.channels
    |> Map.values
    |> Enum.find(fn channel -> channel.name == channel_name end)
    |> Map.get(:id)
  end

  @doc ~S"""
  Turns a Slack user ID (`"U…"`) or direct message ID (`"D…"`) into a string in
  the format "@USER_NAME".
  """
  def lookup_user_name(direct_message_id = "D" <> _id, slack) do
    lookup_user_name(slack.ims[direct_message_id].user, slack)
  end
  def lookup_user_name(user_id = "U" <> _id, slack) do
    "@" <> slack.users[user_id].name
  end

  @doc ~S"""
  Turns a Slack channel ID (`"C…"`) into a string in the format "#CHANNEL_NAME".
  """
  def lookup_channel_name(channel_id = "C" <> _id, slack) do
    "#" <> slack.channels[channel_id].name
  end
end

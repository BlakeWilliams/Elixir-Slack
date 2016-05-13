defmodule Slack.Lookups do
  
  alias Slack.Client
  
  @doc ~S"""
  Turns a string like `"@USER_NAME"` into the ID that Slack understands (`"U…"`).
  """
  def lookup_user_id(name, client) do
    Client.lookup(client, :user, :id, name)
  end

  @doc ~S"""
  Turns a string like `"@USER_NAME"` or a user ID (`"U…"`) into the ID for the
  direct message channel of that user (`"D…"`).  `nil` is returned if a direct
  message channel has not yet been opened.
  """
  def lookup_direct_message_id(name, client) do
    Client.lookup(client, :user, :im, name)
  end

  @doc ~S"""
  Turns a string like `"@CHANNEL_NAME"` into the ID that Slack understands
  (`"C…"`).
  """
  def lookup_channel_id(name, client) do
    Client.lookup(client, :channel, :id, name)
  end

  @doc ~S"""
  Turns a Slack user ID (`"U…"`) or direct message ID (`"D…"`) into a string in
  the format "@USER_NAME".
  """
  def lookup_user_name(user_id, client) do
    Client.lookup(client, :user, :name, user_id)
  end

  @doc ~S"""
  Turns a Slack channel ID (`"C…"`) into a string in the format "#CHANNEL_NAME".
  """
  def lookup_channel_name(channel_id, client) do
    Client.lookup(client, :channel, :name, channel_id)
  end
end

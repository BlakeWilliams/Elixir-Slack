defmodule Slack.Lookups do
  
  alias Slack.Client
  
  @doc """
  Converts between Slack ID formats.
  
  Available conversions: 
    - `:user: [:id, :im, :name]``
    - `:channel: [:id, :name]``
  """
  @spec lookup(Client.t, Atom.t, Atom.t, String.t) :: Map.t
  def lookup(client, type, format, name)
    
  def lookup(_client, :user, :id, id = "U" <> _id), do: id
  def lookup(client, :user, :id, im = "D" <> _id) do
    name = lookup(client, :user, :name, im)
    lookup(client, :user, :id, name)
  end
  def lookup(client, :user, :id, "@" <> user_name) do
    client.users
      |> Map.values
      |> Enum.find(%{ }, fn user -> user.name == user_name end)
      |> Map.get(:id)
  end
  
  def lookup(_client, :user, :im, im = "D" <> _id), do: im
  def lookup(client, :user, :im, name = "@" <> _id) do
    id = lookup(client, :user, :id, name)
    lookup(client, :user, :im, id)
  end
  def lookup(client, :user, :im, id = "U" <> _id) do
    client.ims
      |> Map.values
      |> Enum.find(%{ }, fn im -> im.user == id end)
      |> Map.get(:id)
  end
  
  def lookup(_client, :user, :name, name = "@" <> _id), do: name
  def lookup(client, :user, :name, im_id = "D" <> _id) do
    lookup(client, :user, :name, client.ims[im_id].user)
  end
  def lookup(client, :user, :name, user_id = "U" <> _id) do
    "@" <> client.users[user_id].name
  end
  
  def lookup(_client, :channel, :id, id = "C" <> _id), do: id
  def lookup(client, :channel, :id, "#" <> channel_name) do
    client.channels
      |> Map.values
      |> Enum.find(fn channel -> channel.name == channel_name end)
      |> Map.get(:id)
  end
  
  def lookup(_client, :channel, :name, name = "#" <> _id), do: name
  def lookup(client, :channel, :name, channel_id = "C" <> _id) do
    "#" <> client.channels[channel_id].name
  end
  
  def lookup(_client, _type, _format, _id) do
    nil
  end
  
  @doc ~S"""
  Turns a string like `"@USER_NAME"` into the ID that Slack understands (`"U…"`).
  """
  @spec lookup_user_id(String.t, Client.t) :: String.t
  def lookup_user_id(name, client) do
    lookup(client, :user, :id, name)
  end

  @doc ~S"""
  Turns a string like `"@USER_NAME"` or a user ID (`"U…"`) into the ID for the
  direct message channel of that user (`"D…"`).  `nil` is returned if a direct
  message channel has not yet been opened.
  """
  @spec lookup_direct_message_id(String.t, Client.t) :: String.t
  def lookup_direct_message_id(name, client) do
    lookup(client, :user, :im, name)
  end

  @doc ~S"""
  Turns a string like `"@CHANNEL_NAME"` into the ID that Slack understands
  (`"C…"`).
  """
  @spec lookup_channel_id(String.t, Client.t) :: String.t
  def lookup_channel_id(name, client) do
    lookup(client, :channel, :id, name)
  end

  @doc ~S"""
  Turns a Slack user ID (`"U…"`) or direct message ID (`"D…"`) into a string in
  the format "@USER_NAME".
  """
  @spec lookup_user_name(String.t, Client.t) :: String.t
  def lookup_user_name(user_id, client) do
    lookup(client, :user, :name, user_id)
  end

  @doc ~S"""
  Turns a Slack channel ID (`"C…"`) into a string in the format "#CHANNEL_NAME".
  """
  @spec lookup_channel_name(String.t, Client.t) :: String.t
  def lookup_channel_name(channel_id, client) do
    lookup(client, :channel, :name, channel_id)
  end
end

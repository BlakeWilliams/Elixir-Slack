defmodule Slack.Client do
  @moduledoc """
  A Struct that keeps updated with the state of your Slack team
  as it notices new events.
  """
  
  defstruct [
    socket: nil,
    client: nil,
    token:  nil,
    me:     nil,
    team:   nil,
    bots:     %{},
    channels: %{},
    groups:   %{},
    users:    %{},
    ims:      %{},
  ]
    
  @behaviour Access
  
  @type key :: any
  @type value :: any

  @doc """
  Implements fetch/2 for Access protocol.
  """
  @spec fetch(Client.t, key) :: value
  def fetch(client, key)
  defdelegate fetch(client, key), to: Map
    
  @doc """
  Implements get_and_update/3 for Access protocol.
  """
  @spec get_and_update(Client.t, key, (value -> {value, value})) :: Client.t
  def get_and_update(client, key, function)
  defdelegate get_and_update(client, key, function), to: Map
  
  @doc """
  Notice when a new Slack object has been created.
  
  Available types: `[:channel, :im, :group, :user, :bot]`
  """
  @spec track(Client.t, Atom.t, Map.t) :: Client.t
  def track(client, type, object)
  
  [:channel, :im, :group, :user, :bot] |> Enum.map( fn type ->
    plural_type = type |> Atom.to_string |> Kernel.<>("s") |> String.to_atom
    def track(client, unquote(type), object) do
      put_in client, [unquote(plural_type), object.id], object
    end
  end )
  
  @doc """
  Notices when you join a channel or group.
  
  Available types: `[:channel, :group]`
  """
  @spec join(Client.t, Atom.t, Map.t) :: Client.t
  def join(client, type, object)
  
  def join(client, :channel, channel) do
    client
      |> put_in([:channels, channel.id, :members], channel.members)
      |> put_in([:channels, channel.id, :is_member], true)
  end
  
  def join(client, :group, group) do
    put_in(client, [:groups, group.id], group)
  end
  
  @doc """
  Notices when a user joins a channel or group.
  
  Available types: `[:channel, :group]`
  """
  @spec joined(Client.t, Atom.t, Map.t, Map.t) :: Client.t
  def joined(client, type, object, user)
  
  [:channel, :group] |> Enum.map( fn type ->
    plural_type = type |> Atom.to_string |> Kernel.<>("s") |> String.to_atom
    def joined(client, unquote(type), object, user) do
      update_in(client, [unquote(plural_type), object, :members], &(Enum.uniq([user | &1])))
    end
  end )
  
  @doc """
  Notices when you leave a channel or group.
  
  Available types: `[:channel, :group]`
  """
  @spec leave(Client.t, Atom.t, Map.t) :: Client.t
  def leave(client, type, object)
  
  def leave(client, :channel, channel) do
    put_in(client, [:channels, channel, :is_member], false)
  end
  
  def leave(client, :group, group) do
    update_in(client, [:groups], &(Map.delete(&1, group)))
  end
  
  @doc """
  Notices when a user left a channel or group.
  
  Available types: `[:channel, :group]`
  """
  @spec left(Client.t, Atom.t, Map.t, Map.t) :: Client.t
  def left(client, type, object, user)
  
  [:channel, :group] |> Enum.map( fn type ->
    plural_type = type |> Atom.to_string |> Kernel.<>("s") |> String.to_atom
    def left(client, unquote(type), object, user) do
      update_in(client, [unquote(plural_type), object, :members], &(&1 -- [user]))
    end
  end )
  
  @doc """
  Notices when a channel or group is archived.
  
  Available types: `[:channel, :group]`
  """
  @spec archive(Client.t, Atom.t, Map.t) :: Client.t
  def archive(client, type, object)
  
  [:channel, :group] |> Enum.map( fn type ->
    plural_type = type |> Atom.to_string |> Kernel.<>("s") |> String.to_atom
    def archive(client, unquote(type), object) do
      put_in(client, [unquote(plural_type), object, :is_archived], true)
    end
  end )
  
  @doc """
  Notices when a channel or group is archived.
  
  Available types: `[:channel, :group]`
  """
  @spec unarchive(Client.t, Atom.t, Map.t) :: Client.t
  def unarchive(client, type, object)
  
  [:channel, :group] |> Enum.map( fn type ->
    plural_type = type |> Atom.to_string |> Kernel.<>("s") |> String.to_atom
    def unarchive(client, unquote(type), object) do
      put_in(client, [unquote(plural_type), object, :is_archived], false)
    end
  end )
  
  @doc """
  Notices when a channel or group's name has changed.
  
  Additionally notices when the team's name changes.
  
  Available types: `[:channel, :group, :team]`
  """
  
  @spec rename(Client.t, Atom.t, String.t) :: Client.t
  def rename(client, :team, name) do
    put_in(client, [:team, :name], name)
  end
  
  @spec rename(Client.t, Atom.t, String.t) :: Client.t
  [:channel, :group] |> Enum.map( fn type ->
    plural_type = type |> Atom.to_string |> Kernel.<>("s") |> String.to_atom
    def rename(client, unquote(type), object) do
      put_in(client, [unquote(plural_type), object.id, :name], object.name)
    end
  end )
  
  @doc """
  Notices when a bot or user changes.
  
  Also notices when a user's presence has changed.
  
  Available types: `[:user, :bot]`
  """
  
  @spec change(Client.t, Atom.t, Map.t) :: Client.t
  [:user, :bot] |> Enum.map( fn type ->
    plural_type = type |> Atom.to_string |> Kernel.<>("s") |> String.to_atom
    def change(client, unquote(type), object) do
      put_in(client, [unquote(plural_type), object.id], object)
    end
  end )
  
  @spec change(Client.t, Atom.t, Map.t, String.t) :: Client.t
  def change(client, :user, user, presence) do
    put_in(client, [:users, user, :presence], presence)
  end
  
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
   
end
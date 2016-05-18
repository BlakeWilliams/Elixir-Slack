defmodule Slack.Client do
  @moduledoc """
  A struct that represents the state of the Slack team you've connected to.
  """
  
  @behaviour Access
  
  @type key :: any
  @type value :: any

  @spec fetch(Client.t, key) :: value
  def fetch(client, key)
  defdelegate fetch(client, key), to: Map
    
  @spec get_and_update(Client.t, key, (value -> {value, value})) :: Client.t
  def get_and_update(client, key, function)
  defdelegate get_and_update(client, key, function), to: Map
  
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
  
  @doc """
  Update client state when an update is received.
  
  Available types: `[:channel, :im, :group, :user, :bot]`
  """
  @spec track(Client.t, Atom.t, Map.t) :: Client.t
  def track(client, type, object)
  
  trackable = [
    :channel,
    :im,
    :group,
    :user,
    :bot,
  ]
  
  trackables = trackable |> Enum.map(fn(type) ->
    {type, "#{type}s" |> String.to_atom}
  end)
  
  trackables |> Enum.map(fn({type, plural}) ->
    def track(client, unquote(type), object) do
      put_in client, [unquote(plural), object.id], object
    end
  end)
  
  @doc """
  Updates Slack client when a channel or group is joined.
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
  Updates Slack client when a user joins channel or group is joined.
  """
  @spec joined(Client.t, Atom.t, Map.t, Map.t) :: Client.t
  def joined(client, type, object, user)
  
  joinable = [
    :channel,
    :group,
  ]
  
  joinables = joinable |> Enum.map(fn(type) ->
    {type, "#{type}s" |> String.to_atom}
  end)
  
  joinables |> Enum.map(fn({type, plural}) ->
    def joined(client, unquote(type), object, user) do
      update_in(client, [unquote(plural), object, :members], &(Enum.uniq([user | &1])))
    end
  end)
  
  @doc """
  Updates client state when you leave a channel or group.
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
  Updates client state when a user leaves a channel or group.
  """
  @spec left(Client.t, Atom.t, Map.t, Map.t) :: Client.t
  def left(client, type, object, user)
  
  leavable = [
    :channel,
    :group,
  ]
  
  leavables = leavable |> Enum.map(fn(type) ->
    {type, "#{type}s" |> String.to_atom}
  end)
  
  leavables |> Enum.map(fn({type, plural}) ->
    def left(client, unquote(type), object, user) do
      update_in(client, [unquote(plural), object, :members], &(&1 -- [user]))
    end
  end)
  
  @doc """
  Updates client state when a channel or group is archived.
  """
  @spec archive(Client.t, Atom.t, Map.t) :: Client.t
  def archive(client, type, object)
  
  archivable = [
    :channel,
    :group,
  ]
  
  archivables = archivable |> Enum.map(fn(type) ->
    {type, "#{type}s" |> String.to_atom}
  end)
  
  archivables |> Enum.map(fn({type, plural}) ->
    def archive(client, unquote(type), object) do
      put_in(client, [unquote(plural), object, :is_archived], true)
    end
  end)
  
  @doc """
  Updates client state when a channel or group is archived.
  """
  @spec unarchive(Client.t, Atom.t, Map.t) :: Client.t
  def unarchive(client, type, object)
  
  unarchivable = [
    :channel,
    :group,
  ]
  
  unarchivables = unarchivable |> Enum.map(fn(type) ->
    {type, "#{type}s" |> String.to_atom}
  end)
  
  unarchivables |> Enum.map(fn({type, plural}) ->
    def unarchive(client, unquote(type), object) do
      put_in(client, [unquote(plural), object, :is_archived], false)
    end
  end)
  
  @doc """
  Updates client state when a channel, group, or team's name changes.
  """
  @spec rename(Client.t, Atom.t, String.t) :: Client.t
  def rename(client, type, name)
  
  def rename(client, :team, name) do
    put_in(client, [:team, :name], name)
  end
  
  renameable = [
    :channel,
    :group,
  ]
  
  renameables = renameable |> Enum.map(fn(type) ->
    {type, "#{type}s" |> String.to_atom}
  end)
  
  renameables |> Enum.map(fn({type, plural}) ->
    def rename(client, unquote(type), object) do
      put_in(client, [unquote(plural), object.id, :name], object.name)
    end
  end)
  
  @doc """
  Updates client state when a user's presence changes.
  """
  @spec change(Client.t, Atom.t, Map.t, String.t) :: Client.t
  def change(client, :user, user, presence) do
    put_in(client, [:users, user, :presence], presence)
  end
  
  
  @doc """
  Updates client state when a bot or user changes.
  """
  @spec change(Client.t, Atom.t, Map.t) :: Client.t
  
  changeable = [
    :user,
    :bot,
  ]
  
  changeables = changeable |> Enum.map(fn(type) ->
    {type, "#{type}s" |> String.to_atom}
  end)
  
  changeables |> Enum.map(fn({type, plural}) ->
    def change(client, unquote(type), object) do
      put_in(client, [unquote(plural), object.id], object)
    end
  end)
end
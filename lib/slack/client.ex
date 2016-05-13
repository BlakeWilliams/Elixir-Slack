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
    def track(client = %__MODULE__{}, unquote(type), object) do
      put_in client, [unquote(plural_type), object.id], object
    end
  end )
  
  @doc """
  Notices when you join a channel or group.
  
  Available types: `[:channel, :group]`
  """
  @spec join(Client.t, Atom.t, Map.t) :: Client.t
  def join(client, type, object)
  
  def join(client = %__MODULE__{}, :channel, channel) do
    client
      |> put_in([:channels, channel.id, :members], channel.members)
      |> put_in([:channels, channel.id, :is_member], true)
  end
  
  def join(client = %__MODULE__{}, :group, group) do
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
    def joined(client = %__MODULE__{}, unquote(type), object, user) do
      update_in(client, [unquote(plural_type), object, :members], &(Enum.uniq([user | &1])))
    end
  end )
  
  @doc """
  Notices when you leave a channel or group.
  
  Available types: `[:channel, :group]`
  """
  @spec leave(Client.t, Atom.t, Map.t) :: Client.t
  def leave(client, type, object)
  
  def leave(client = %__MODULE__{}, :channel, channel) do
    put_in(client, [:channels, channel, :is_member], false)
  end
  
  def leave(client = %__MODULE__{}, :group, group) do
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
    def left(client = %__MODULE__{}, unquote(type), object, user) do
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
    def archive(client = %__MODULE__{}, unquote(type), object) do
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
    def unarchive(client = %__MODULE__{}, unquote(type), object) do
      put_in(client, [unquote(plural_type), object, :is_archived], false)
    end
  end )
  
  @doc """
  Notices when a channel or group's name has changed.
  
  Additionally notices when the team's name changes.
  
  Available types: `[:channel, :group, :team]`
  """
  
  @spec rename(Client.t, Atom.t, String.t) :: Client.t
  def rename(client = %__MODULE__{}, :team, name) do
    put_in(client, [:team, :name], name)
  end
  
  @spec rename(Client.t, Atom.t, String.t) :: Client.t
  [:channel, :group] |> Enum.map( fn type ->
    plural_type = type |> Atom.to_string |> Kernel.<>("s") |> String.to_atom
    def rename(client = %__MODULE__{}, unquote(type), object) do
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
    def change(client = %__MODULE__{}, unquote(type), object) do
      put_in(client, [unquote(plural_type), object.id], object)
    end
  end )
  
  @spec change(Client.t, Atom.t, Map.t, String.t) :: Client.t
  def change(client = %__MODULE__{}, :user, user, presence) do
    put_in(client, [:users, user, :presence], presence)
  end
   
end
defmodule Slack.State do
  @moduledoc """
  A struct for holding the state of a Slack RTM session using Agents as simple
  wrappers around holding users and channels. For example, you could fetch all
  channels from an existing state struct:

  ```
  Slack.State.channels(state) # %{"1": %{id: 1, name: "Foo"}}
  ```

  You can also manually update the list of channels:

  ```
  Slack.State.update_channels(state, [%{id: 2, name: "bar"}])
  Slack.State.channels(state) # %{"1": %{id: 1, name: "Foo"}, "2": %{id: 2, name: "bar"}}
  ```

  You also have access to who you're currently logged in as through the `me`
  field.
  """
  defstruct socket: nil, channels: nil, me: nil, users: nil
  @type state :: %__MODULE__{
    socket: :websocket_client.Req,
    channels: pid,
    me: Map,
    users: pid
  }

  @doc false
  def new(socket, rtm_response)  do
    {:ok, users_pid} = Agent.start(fn -> %{} end)
    {:ok, channels_pid} = Agent.start(fn -> %{} end)

    state = %Slack.State{
      channels: channels_pid,
      me: rtm_response.self,
      socket: socket,
      users: users_pid
    }

    update_channels(state, rtm_response.channels)
    update_users(state, rtm_response.users)

    state
  end

  @doc "Retreive all channels from the state"
  def channels(%__MODULE__{channels: channels}), do: get_agent_state(channels)

  @doc "Retreive all users from the state"
  def users(%__MODULE__{users: users}), do: get_agent_state(users)

  @doc """
  Takes a state and a list of channels and adds the channels to the map of stored channels.
  """
  def update_channels(state, channels), do: parse_and_update(state.channels, channels)

  @doc """
  Takes a state and a list of users and adds the users to the map of
  stored users.
  """
  def update_users(state, users), do: parse_and_update(state.users, users)

  defp get_agent_state(pid) do
    Agent.get(pid, fn (value) ->
      value
    end)
  end

  defp parse_and_update(pid, list) do
    Agent.update(pid, fn (existing_list) ->
      new_items = list_to_map(list)
      Map.merge(existing_list, new_items)
    end)
  end

  defp list_to_map(list) do
    Enum.reduce(list, %{}, fn (item, map) ->
      id = item.id |> String.to_atom
      Map.put(map, id, item)
    end)
  end
end

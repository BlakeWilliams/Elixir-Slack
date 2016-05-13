defmodule Slack.Handlers do
  @moduledoc """
  Defines `handle_slack/3` methods for keeping the `Slack.Client` struct
  up to date.
  """
  
  alias Slack.Client
  import Client

  @doc """
  Pattern matches against messages and returns updated Slack state.
  """
  @spec handle_slack(Map.t, Client.t) :: {Atom.t, Client.t}
  def handle_slack(event, client)
  
# CHANNELS

  def handle_slack(%{type: "channel_created", channel: channel}, client) do
    {:ok, track(client, :channel, channel)}
  end
  
  def handle_slack(%{type: "channel_joined", channel: channel}, client) do
    {:ok, join(client, :channel, channel)}
  end

  def handle_slack(%{type: "message", subtype: "channel_join", channel: channel, user: user}, client) do
    {:ok, joined(client, :channel, channel, user)}
  end

  def handle_slack(%{type: "channel_rename", channel: channel}, client) do
    {:ok, rename(client, :channel, channel)}
  end
  
  def handle_slack(%{type: "channel_archive", channel: channel}, client) do
    {:ok, archive(client, :channel, channel)}
  end
  
  def handle_slack(%{type: "channel_unarchive", channel: channel}, client) do
    {:ok, unarchive(client, :channel, channel)}
  end
  
  def handle_slack(%{type: "message", subtype: "channel_leave", channel: channel, user: user}, client) do
    {:ok, left(client, :channel, channel, user)}
  end

  def handle_slack(%{type: "channel_left", channel: channel}, client) do
    {:ok, leave(client, :channel, channel)}
  end
  
# IMS

  def handle_slack(%{type: "im_created", channel: im}, client) do
    {:ok, track(client, :im, im)}
  end
  
# GROUPS

  def handle_slack(%{type: "group_joined", channel: group}, client) do
    {:ok, join(client, :group, group)}
  end

  def handle_slack(%{type: "message", subtype: "group_join", channel: group, user: user}, client) do
    {:ok, joined(client, :group, group, user)}
  end

  def handle_slack(%{type: "group_rename", channel: group}, client) do
    {:ok, rename(client, :group, group)}
  end
  
  def handle_slack(%{type: "group_archive", channel: group}, client) do
    {:ok, archive(client, :group, group)}
  end
  
  def handle_slack(%{type: "group_unarchive", channel: group}, client) do
    {:ok, unarchive(client, :group, group)}
  end
  
  def handle_slack(%{type: "message", subtype: "group_leave", channel: group, user: user}, client) do
    {:ok, left(client, :group, group, user)}
  end

  def handle_slack(%{type: "group_left", channel: group}, client) do
    {:ok, leave(client, :group, group)}
  end
  
# TEAM

  def handle_slack(%{type: "team_join", user: user}, client) do
    {:ok, track(client, :user, user)}
  end

  def handle_slack(%{type: "team_rename", name: name}, client) do
    {:ok, rename(client, :team, name)}
  end
  
# USERS

  def handle_slack(%{type: "presence_change", user: user, presence: presence}, client) do
    {:ok, change(client, :user, user, presence)}
  end
  
  def handle_slack(%{type: "user_change", user: user}, client) do
    {:ok, change(client, :user, user)}
  end
  
# BOTS

  def handle_slack(%{type: "bot_added", bot: bot}, client) do
    {:ok, track(client, :bot, bot)}
  end
  
  def handle_slack(%{type: "bot_changed", bot: bot}, client) do
    {:ok, change(client, :bot, bot)}
  end
  
# CATCHALL

  def handle_slack(%{type: _type}, client) do
    {:ok, client}
  end
  
end

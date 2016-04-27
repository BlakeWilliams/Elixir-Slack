defmodule Slack.Handlers do
  @moduledoc """
  Defines `handle_slack/3` methods for keeping the `slack` argument in `Slack`
  up to date.
  """

  @doc """
  Pattern matches against messages and returns updated Slack state.
  """
  @spec handle_slack(Map, Map) :: {Symbol, Map}
  def handle_slack(%{type: "channel_created", channel: channel}, slack) do
    {:ok, put_in(slack, [:channels, channel.id], channel)}
  end

  def handle_slack(%{type: "channel_joined", channel: channel}, slack) do
    slack = slack
    |> put_in([:channels, channel.id, :members], channel.members)
    |> put_in([:channels, channel.id, :is_member], true)
    {:ok, slack}
  end

  def handle_slack(%{type: "group_joined", channel: channel}, slack) do
    {:ok, put_in(slack, [:groups, channel.id], channel)}
  end

  def handle_slack(%{type: "message", subtype: "channel_join", channel: channel, user: user}, slack) do
    {:ok, put_in(slack, [:channels, channel, :members], [user | slack[:channels][channel][:members]])}
  end

  def handle_slack(%{type: "message", subtype: "group_join", channel: channel, user: user}, slack) do
    {:ok, update_in(slack, [:groups, channel, :members], &(Enum.uniq([user | &1])))}
  end

  def handle_slack(%{type: "channel_left", channel: channel}, slack) do
    {:ok, put_in(slack, [:channels, channel.id, :is_member], false)}
  end

  def handle_slack(%{type: "group_left", channel: channel}, slack) do
    {:ok, update_in(slack, [:groups], &(Map.delete(&1, channel)))}
  end

  Enum.map(["channel", "group"], fn (type) ->
    plural_atom = String.to_atom(type <> "s")

    def handle_slack(%{type: unquote(type <> "_rename"), channel: channel}, slack) do
      {:ok, put_in(slack, [unquote(plural_atom), channel.id, :name], channel.name)}
    end
    def handle_slack(%{type: unquote(type <> "_archive"), channel: channel}, slack) do
      {:ok, put_in(slack, [unquote(plural_atom), channel, :is_archived], true)}
    end
    def handle_slack(%{type: unquote(type <> "_unarchive"), channel: channel}, slack) do
      {:ok, put_in(slack, [unquote(plural_atom), channel, :is_archived], false)}
    end
    def handle_slack(%{type: "message", subtype: unquote(type <> "_leave"), channel: channel, user: user}, slack) do
      {:ok, update_in(slack, [unquote(plural_atom), channel, :members], &(&1 -- [user]))}
    end
  end)

  def handle_slack(%{type: "team_rename", name: name}, slack) do
    {:ok, put_in(slack, [:team, :name], name)}
  end

  Enum.map(["team_join", "user_change"], fn (type) ->
    def handle_slack(%{type: unquote(type), user: user}, slack) do
      {:ok, put_in(slack, [:users, user.id], user)}
    end
  end)

  Enum.map(["bot_added", "bot_changed"], fn (type) ->
    def handle_slack(%{type: unquote(type), bot: bot}, slack) do
      {:ok, put_in(slack, [:bots, bot.id], bot)}
    end
  end)

  def handle_slack(%{type: "im_created", channel: channel}, slack) do
    {:ok, put_in(slack, [:ims, channel.id], channel)}
  end

  def handle_slack(%{type: _type}, slack) do
    {:ok, slack}
  end
end

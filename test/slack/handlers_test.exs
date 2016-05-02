defmodule Slack.HandlersTest do
  use ExUnit.Case
  alias Slack.Handlers

  test "channel_joined sets is_member to true" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "channel_joined", channel: %{id: "123", members: ["123456", "654321"]}},
      slack
    )

    assert new_slack.channels["123"].is_member == true
    assert new_slack.channels["123"].members == ["123456", "654321"]
  end

  test "channel_left sets is_member to false" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "channel_left", channel: "123"},
      slack
    )

    assert new_slack.channels["123"].is_member == false
  end

  test "channel_rename renames the channel" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "channel_rename", channel: %{id: "123", name: "bar"}},
      slack
    )

    assert new_slack.channels["123"].name == "bar"
  end

  test "channel_archive marks channel as archived" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "channel_archive", channel: "123"},
      slack
    )

    assert new_slack.channels["123"].is_archived == true
  end

  test "channel_unarchive marks channel as not archived" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "channel_unarchive", channel: "123"},
      slack
    )

    assert new_slack.channels["123"].is_archived == false
  end

  test "channel_leave marks channel as not archived" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "channel_unarchive", channel: "123"},
      slack
    )

    assert new_slack.channels["123"].is_archived == false
  end

  test "team_rename renames team" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "team_rename", name: "Bar"},
      slack
    )

    assert new_slack.team.name == "Bar"
  end

  test "team_join adds user to users" do
    user_length = Map.size(slack.users)
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "team_join", user: %{id: "345"}},
      slack
    )

    assert Map.size(new_slack.users) == user_length + 1
  end

  test "user_change updates user" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "team_join", user: %{id: "123", name: "bar"}},
      slack
    )

    assert new_slack.users["123"].name == "bar"
  end

  test "bot_added adds bot to bots" do
    bot_length = Map.size(slack.bots)

    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "bot_added", bot: %{id: "345", name: "new"}},
      slack
    )

    assert Map.size(new_slack.bots) == bot_length + 1
  end

  test "bot_changed updates bot in bots" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "bot_added", bot: %{id: "123", name: "new"}},
      slack
    )

    assert new_slack.bots["123"].name == "new"
  end

  test "channel_join message should add member" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "message", subtype: "channel_join", user: "U456", channel: "123"},
      slack
    )

    assert (new_slack.channels["123"].members |> Enum.sort) == ["U123", "U456"]
  end

  test "channel_leave message should remove member" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "message", subtype: "channel_leave", user: "U123", channel: "123"},
      slack
    )

    assert new_slack.channels["123"].members == []
  end

  test "presence_change message should update user" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{presence: "testing", type: "presence_change", user: "123"},
      slack
    )

    assert new_slack.users["123"].presence == "testing"
  end

  test "group_joined event should add group" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "group_joined", channel: %{id: "G123", members: ["U123", "U456"]}},
      slack
    )

    assert new_slack.groups["G123"]
    assert new_slack.groups["G123"].members == ["U123", "U456"]
  end

  test "group_join message should add user to member list" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "message", subtype: "group_join", channel: "G000", user: "U000"},
      slack
    )

    assert Enum.member?(new_slack.groups["G000"][:members], "U000")
  end

  test "group_leave message should remove user from member list" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "message", subtype: "group_leave", channel: "G000", user: "U111"},
      slack
    )

    refute Enum.member?(new_slack.groups["G000"].members, "U111")
  end

  test "group_left message should remove group altogether" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "group_left", channel: "G000"},
      slack
    )

    refute new_slack.groups["G000"]
  end

  test "im_created message should add direct message channel to list" do
    channel = %{name: "channel", id: "C456"}
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "im_created", channel: channel},
      slack
    )

    assert new_slack.ims == %{"C456" => channel}
  end

  defp slack do
    %{
      channels: %{
        "123" => %{
          id: 123,
          name: "foo",
          is_member: nil,
          is_archived: nil,
          members: ["U123"]
        }
      },
      team: %{
        name: "Foo",
      },
      users: %{
        "123" => %{
          name: "Bar",
          presence: "active"
        }
      },
      groups: %{
        "G000" => %{
          name: "secret-group",
          members: ["U111", "U222"]
        }
      },
      bots: %{
        "123" => %{
          name: "Bot"
        }
      },
      ims: %{ }
    }
  end
end

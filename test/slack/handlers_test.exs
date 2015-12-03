defmodule Slack.HandlersTest do
  use ExUnit.Case
  alias Slack.Handlers

  test "channel_joined sets is_member to true" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "channel_joined", channel: %{id: "123"}},
      slack
    )

    assert new_slack.channels["123"].is_member == true
  end

  test "channel_joined sets is_member to true" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "channel_left", channel: %{id: "123"}},
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

  test "im_created updates adds to ims" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "im_created", channel: %{id: "234"}, user: "345"},
      slack
    )

    assert new_slack.ims["234"].user == "345"
    assert new_slack.ims["234"].id == "234"
  end

  test "im_close removes from ims" do
    {:ok, new_slack} = Handlers.handle_slack(
      %{type: "im_close", channel: %{id: "123"}, user: "456"},
      slack
    )

    assert new_slack.ims["123"] == nil
  end

  defp slack do
    %{
      token: "token",
      channels: %{
        "123" => %{
          id: 123,
          name: "foo",
          is_member: nil,
          is_archived: nil
        }
      },
      team: %{
        name: "Foo",
      },
      users: %{
        "123": %{
          name: "Bar"
        }
      },
      bots: %{
        "123": %{
          name: "Bot"
        }
      },
      ims: %{
        "123": %{
          id: "123",
          is_im: true,
          user: "456",
          created: 1416698705,
          is_user_deleted: false
        }
      }
    }
  end
end

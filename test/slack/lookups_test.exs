defmodule Slack.LookupsTest do
  use ExUnit.Case
  alias Slack.Lookups

  test "turns @user into a user identifier" do
    slack = %{users: %{"U123" => %{name: "user", id: "U123", profile: %{display_name: "user"}}}}
    assert Lookups.lookup_user_id("@user", slack) == "U123"
  end

  test "turns @user into direct message identifier, if the channel exists" do
    slack = %{
      users: %{"U123" => %{name: "user", id: "U123", profile: %{display_name: "user"}}},
      ims: %{"D789" => %{user: "U123", id: "D789"}}
    }

    assert Lookups.lookup_direct_message_id("@user", slack) == "D789"
    assert Lookups.lookup_direct_message_id("@missing", slack) == nil
  end

  test "turns a user identifier into direct message identifier, if the channel exists" do
    slack = %{ims: %{"D789" => %{user: "U123", id: "D789"}}}
    assert Lookups.lookup_direct_message_id("U123", slack) == "D789"
    assert Lookups.lookup_direct_message_id("U000", slack) == nil
  end

  test "turns #channel into a channel identifier" do
    slack = %{channels: %{"C456" => %{name: "channel", id: "C456"}}}
    assert Lookups.lookup_channel_id("#channel", slack) == "C456"
  end

  test "turns private #channel into a group identifier" do
    slack = %{
      channels: %{},
      groups: %{"G456" => %{name: "private", id: "G456"}}
    }

    assert Lookups.lookup_channel_id("#private", slack) == "G456"
  end

  test "turns unknown #channel into nil" do
    slack = %{
      channels: %{},
      groups: %{}
    }

    assert Lookups.lookup_channel_id("#unknown", slack) == nil
  end

  test "turns a user identifier into @user for user ids that start with U" do
    slack = %{users: %{"U123" => %{name: "user", id: "U123", profile: %{display_name: "user"}}}}
    assert Lookups.lookup_user_name("U123", slack) == "@user"
  end

  test "turns a user identifier into @user for user ids that start with W" do
    slack = %{users: %{"W123" => %{name: "user", id: "W123", profile: %{display_name: "user"}}}}
    assert Lookups.lookup_user_name("W123", slack) == "@user"
  end

  test "turns a direct message identifier into @user" do
    slack = %{
      users: %{"U123" => %{name: "user", id: "U123", profile: %{display_name: "user"}}},
      ims: %{"D789" => %{user: "U123", id: "D789"}}
    }

    assert Lookups.lookup_user_name("D789", slack) == "@user"
  end

  test "turns a channel identifier into #channel" do
    slack = %{channels: %{"C456" => %{name: "channel", id: "C456"}}}
    assert Lookups.lookup_channel_name("C456", slack) == "#channel"
  end

  test "turns a private channel identifier into #channel" do
    slack = %{
      channels: %{},
      groups: %{"G456" => %{name: "channel", id: "G456"}}
    }

    assert Lookups.lookup_channel_name("G456", slack) == "#channel"
  end
end

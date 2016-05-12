defmodule Slack.LookupsTest do
  use ExUnit.Case
  alias Slack.Lookups

  test "turns @user into a user identifier" do
    slack = %Slack{users: %{"U123" => %{name: "user", id: "U123"}}}
    assert Lookups.lookup_user_id("@user", slack) == "U123"
  end

  test "turns @user into direct message identifier, if the channel exists" do
    slack = %Slack{
      users: %{"U123" => %{name: "user", id: "U123"}},
      ims: %{"D789" => %{user: "U123", id: "D789"}}
    }
    assert Lookups.lookup_direct_message_id("@user", slack) == "D789"
    assert Lookups.lookup_direct_message_id("@missing", slack) == nil
  end

  test "turns a user identifier into direct message identifier, if the channel exists" do
    slack = %Slack{ims: %{"D789" => %{user: "U123", id: "D789"}}}
    assert Lookups.lookup_direct_message_id("U123", slack) == "D789"
    assert Lookups.lookup_direct_message_id("U000", slack) == nil
  end

  test "turns #channel into a channel identifier" do
    slack = %Slack{channels: %{"C456" => %{name: "channel", id: "C456"}}}
    assert Lookups.lookup_channel_id("#channel", slack) == "C456"
  end

  test "turns a user identifier into @user" do
    slack = %Slack{users: %{"U123" => %{name: "user", id: "U123"}}}
    assert Lookups.lookup_user_name("U123", slack) == "@user"
  end

  test "turns a direct message identifier into @user" do
    slack = %Slack{
      users: %{"U123" => %{name: "user", id: "U123"}},
      ims: %{"D789" => %{user: "U123", id: "D789"}}
    }
    assert Lookups.lookup_user_name("D789", slack) == "@user"
  end

  test "turns a channel identifier into #channel" do
    slack = %Slack{channels: %{"C456" => %{name: "channel", id: "C456"}}}
    assert Lookups.lookup_channel_name("C456", slack) == "#channel"
  end
end

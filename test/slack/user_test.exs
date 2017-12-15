defmodule Slack.UserTest do
  use ExUnit.Case
  alias Slack.User

  describe "new/1" do
    test "returns user struct" do
      assert %User{} = User.new(id: "C024BE91L", name: "My user")
    end

    test "handles different arg orders" do
      assert %User{} = User.new(name: "My user", id: "C024BE91L")
    end

    test "raises exception on missing options" do
      assert_raise ArgumentError, fn -> User.new(name: "My user") end
    end
  end

  describe "new_from_id/2" do
    test "looks user up" do
      assert {:ok, %User{}} = User.new_from_id(slack(), "Umyuserid")
    end

    test "looks bots up" do
      assert {:ok, %User{}} = User.new_from_id(slack(), "Bmybotid")
    end

    test "raises argument error for invalid user ids" do
      assert {:error, ""<>_} = User.new_from_id(slack(), "Ubogusid")
    end

  end

  ### Background & support

  defp slack() do
    %Slack.State{
      users: %{
        "Umyuserid" => %{name: "My user"},
      },
      bots: %{
        "Bmybotid" => %{name: "My bot"},
      }

    }
  end
end

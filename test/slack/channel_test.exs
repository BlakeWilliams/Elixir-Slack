defmodule Slack.ChannelTest do
  use ExUnit.Case
  alias Slack.Channel

  describe "new/1" do
    test "returns channel struct" do
      assert %Channel{} = Channel.new(id: "C024BE91L", name: "My channel")
    end

    test "handles different arg orders" do
      assert Channel.new(name: "My channel", id: "C024BE91L")
    end

    test "raises exception on missing options" do
      assert_raise ArgumentError, fn -> Channel.new(name: "My channel") end
    end
  end

  describe "new_from_id/2" do
    test "looks channel up" do
      assert {:ok, %Channel{}} = Channel.new_from_id(slack(), "Cmychannelid")
    end

    test "returns error tuple for invalid channel ids" do
      assert {:error, ""<>_} = Channel.new_from_id(slack(), "Cbogusid")
    end

  end

  # Background & support
  # ----

  defp slack() do
    %Slack.State{
      channels: %{
        "Cmychannelid" => %{name: "My channel"}
      }
    }
  end
end

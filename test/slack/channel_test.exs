defmodule Slack.ChannelTest do
  use ExUnit.Case
  alias Slack.Channel

  describe "new/1" do
    test "returns channel struct" do
      assert Channel == Channel.new(id: "C024BE91L", name: "My channel").__struct__
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
      assert channel?(Channel.new_from_id(slack(), "Cmychannelid"))
    end

    test "raises argument error for invalid channel ids" do
      assert_raise ArgumentError, fn -> Channel.new_from_id(slack(), "Cbogusid") end
    end

  end

  # Background & support
  # ----

  def slack() do
    %Slack.State{
      channels: %{
        "Cmychannelid" => %{name: "My channel"}
      }
    }
  end

  def channel?(thing) do
    Channel = thing.__struct__
  end
end

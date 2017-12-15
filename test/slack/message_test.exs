
defmodule Slack.MessageTest do
  use ExUnit.Case
  alias Slack.{Message, Channel, FakeWebApi}

  setup do
    FakeWebApi.start_link

    :ok
  end

  describe "new/1" do
    test "returns message struct" do
      assert %Message{} = Message.new(channel: channel(), sender: user(), ts: "1355517523.000005", text: "My message")
    end

    test "handles different arg orders" do
      assert %Message{} = Message.new(text: "My message", channel: channel(), ts: "1355517523.000005", sender: user())
    end

    test "raises exception on missing options" do
      assert_raise ArgumentError, fn -> Message.new(text: "My message") end
    end
  end


  describe "new_from_event/1" do
    test "returns message struct" do
      message_event = %{
        channel: "Ctestchannel",
        user: "Utestuser",
        ts: "1355517523.000005",
        text: "My message"
      }

      assert {:ok, %Message{}} = Message.new_from_event(slack(), message_event)
    end
  end

  describe "permalink/2" do
    test "returns {ok, url}" do
      msg = Message.new(channel: channel(), sender: user(), ts: "1355517523.000005", text: "My message")

      assert {:ok, "http://example.com/archives/Ctestchannel/1355517523.000005"} ==
        Message.permalink(slack(), msg)
    end

    test "calls chat.getPermalink api method" do
      msg = Message.new(channel: channel(), sender: user(), ts: "1355517523.000005", text: "My message")
      Message.permalink(slack(), msg)

      assert called_api_method?("chat.getPermalink")
    end

    test "passes message timestamp argument" do
      msg = Message.new(channel: channel(), sender: user(), ts: "1355517523.000005", text: "My message")
      Message.permalink(slack(), msg)

      assert passed_api_argument?(:message_ts, "1355517523.000005")
    end

    test "passes channel argument" do
      msg = Message.new(channel: channel(), sender: user(), ts: "1355517523.000005", text: "My message")
      Message.permalink(slack(), msg)

      assert passed_api_argument?(:channel, "Ctestchannel")
    end

  end

  # Background & support
  # ----

  defp channel() do
    Channel.new(id: "Ctestchannel", name: "Test channel")
  end
  defp user(), do:  nil
  defp slack() do
    %Slack.State{
      channels: %{
        "Ctestchannel" => %{
          name: "test channel"
         }
      },
      users: %{
        "Utestuser" => %{
          name: "test user"
        }
      }
    }
  end

  defp called_api_method?(api_method) do
    api_method ==
      FakeWebApi.calls
      |> Enum.at(0)
      |> Map.fetch!(:api_method)
  end

  def passed_api_argument?(name, value) do
    FakeWebApi.calls
    |> Enum.at(0)
    |> Map.fetch!(:form_data)
    |> Enum.any?(fn {k,v} -> k == name && v == value end)
  end
end

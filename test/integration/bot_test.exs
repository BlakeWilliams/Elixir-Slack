defmodule Slack.Integration.BotTest do
  use ExUnit.Case, async: false
  import Mock
  alias Slack.Web.{Bots, Channels, Groups, Im, Users}

  defmodule Bot do
    use Slack

    def handle_event(message = %{type: "message", text: text}, slack, state) do
      send_message(String.reverse(text), message.channel, slack)
      {:ok, state}
    end

    def handle_event(_, _, state), do: {:ok, state}
  end

  setup_all do
    Slack.FakeSlack.start_link()

    on_exit(fn ->
      Slack.FakeSlack.stop()
    end)
  end

  test "can connect and respond" do
    with_mocks([
      {Bots, [], [info: fn _token -> %{"bot" => %{id: "123"}} end]},
      {Channels, [], [list: fn _token -> %{"channels" => [%{id: "123"}]} end]},
      {Groups, [], [list: fn _token -> %{"groups" =>  [%{id: "123"}]} end]},
      {Im, [], [list: fn _token -> %{"ims" =>  [%{id: "123"}]} end]},
      {Users, [], [list: fn _token -> %{"members" =>  [%{id: "123"}]} end]}
    ]) do
      Application.put_env(:slack, :test_pid, self())
      {:ok, _pid} = Slack.Bot.start_link(Bot, [], "xyz")

      assert authenticated_with_token?("xyz")

      websocket_pid = get_websocket_pid()

      send_message_to_client(websocket_pid, "hello!")
      assert bot_sent_message?("!olleh")
    end
  end

  defp authenticated_with_token?(token) do
    receive do
      {:token, ^token} -> true
    after
      100 -> false
    end
  end

  defp get_websocket_pid do
    receive do
      {:websocket_connected, websocket_pid} -> websocket_pid
    after
      100 -> false
    end
  end

  defp bot_sent_message?(text) do
    receive do
      {:bot_message, %{"text" => ^text}} -> true
    after
      100 -> false
    end
  end

  defp send_message_to_client(pid, message) do
    send(pid, Poison.encode!(%{type: "message", text: message, channel: "C0123abc"}))
  end
end

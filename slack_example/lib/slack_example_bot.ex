defmodule SlackExampleBot do
  use Slack

  def start(_state, _opts) do
    SlackExampleBot.start_link(System.get_env("SLACK_TOKEN") || "xoxb-12616305728-vkUgzqNVxHNetOz42OD3xGxZ", [])
  end

  def init(initial_state, slack) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, initial_state}
  end

  def handle_message(message = %{type: "message"}, slack, state) do
    message_to_send = "Received #{length(state)} messages so far!"
    send_message(message_to_send, message.channel, slack)
    {:ok, state ++ [message.text]}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end
end


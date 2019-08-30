defmodule Slack.CommandHandler.EcoCommandHandler do
  @moduledoc """
  Echo Comand Handler ecos the message back to the user.
  """

  alias Slack.Message

  @behaviour Slack.CommandHandler

  @impl Slack.CommandHandler
  def handle_command(command, _opts \\ []), do: Message.new(%{text: command.text})
end

defmodule Slack.CommandHandlerTest do
  use ExUnit.Case, async: true

  alias Slack.{
    Command,
    Message,
    CommandHandler,
    CommandHandler.EcoCommandHandler
  }

  @command_handlers [
    CommandHandler.new(%{
      command: "/eco",
      handler: EcoCommandHandler
    })
  ]

  doctest CommandHandler

  test "running command handlers" do
    command = Command.new(%{command: "/eco", text: "hello world"})
    expected = Message.new(%{text: "hello world"})

    assert expected == Command.run_handlers(command, @command_handlers)
  end
end

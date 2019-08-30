defmodule Slack.CommandHandler do
  @moduledoc """
  This module contains the functions for managing incoming commands from Slack
  Commands webhooks.

  It finds the first command handler that matches the command name and forward
  the command to the command handler.
  """

  alias Slack.Command

  @doc """
  Handle the incoming commnad from Slack Commmands.
  """
  @callback handle_command(command :: Command.t(), opts :: keyword()) :: Slack.Message.t()

  @typedoc """
  Defines a Command Handler.

  * `command`: is the value of the command input from the Slack interface.
  * `handler`: A module that handles the command that matches the `command` name.
  * `opts`: Options are used for custom configuration that your handler would need.
  """
  @type t :: %__MODULE__{
          command: String.t(),
          handler: module(),
          opts: keyword()
        }

  @enforce_keys [:command, :handler]
  defstruct [:command, :handler, :opts]

  @doc """
  Creates a Slack Command Handler.

      iex> Slack.CommandHandler.new(%{
      ...>   command: "/echo",
      ...>   handler: Slack.CommandHandler.EcoCommandHandler
      ...> })
      %Slack.CommandHandler{
        command: "/echo",
        handler: Slack.CommandHandler.EcoCommandHandler
      }
  """
  @spec new(map()) :: t()
  def new(params \\ %{}) do
    struct(__MODULE__, params)
  end

  @doc """
  Find the Command Handler that matches the command and forward the command to
  the command handler.
  """
  @spec run_handlers(Command.t(), [t()]) :: Slack.Message.t()
  def run_handlers(command, command_handlers) do
    command_handlers
    |> Enum.find(&is_command(&1, command))
    |> run_command_handler(command)
  end

  defp is_command(%{command: command}, %{command: command}), do: true
  defp is_command(_command, _command_handler), do: false

  defp run_command_handler(nil, _command), do: ""

  defp run_command_handler(command_handler, command) do
    command_handler.handler.handle_command(command, command_handler.opts)
  end
end

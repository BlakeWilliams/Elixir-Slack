defmodule Slack.Command do
  @moduledoc """
  This module contains functions to work with Slack Commands.

  Read more about it in Slack Official documentation:
    * https://api.slack.com/slash-commands
  """

  alias Slack.CommandHandler

  @typedoc """
  Defines a Slack Command data structure. You can read more about the keys from
  the official documentation.
  """
  @type t :: %__MODULE__{}

  defstruct [
    :channel_id,
    :channel_name,
    :command,
    :response_url,
    :team_domain,
    :team_id,
    :text,
    :token,
    :trigger_id,
    :user_id,
    :user_name
  ]

  @doc """
  Creates a Slack Command struct.

      iex> Slack.Command.new()
      %Slack.Command{
        channel_id: nil,
        channel_name: nil,
        command: nil,
        response_url: nil,
        team_domain: nil,
        team_id: nil,
        text: nil,
        token: nil,
        trigger_id: nil,
        user_id: nil,
        user_name: nil
      }
  """
  @spec new(map()) :: t()
  def new(params \\ %{}) do
    struct(__MODULE__, params)
  end

  defdelegate run_handlers(command, command_handlers), to: CommandHandler
end

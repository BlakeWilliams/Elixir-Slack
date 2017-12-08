defmodule Slack.Channel do
  @moduledoc """
  Functions for interacting with channels in Slack.
  """
  alias Slack.Lookups

  @typedoc """
  Represents a channel in slack.
  """
  @opaque t :: %__MODULE__{}
  defstruct [:id, :name]

  @doc """
  Build a new channel representation.
  """
  @spec new([id: String.t, name: String.t]) :: __MODULE__.t | no_return()
  def new(opts) do
    try do
      %__MODULE__{
        id: Keyword.fetch!(opts, :id),
        name: Keyword.fetch!(opts, :name)
      }

    rescue
      err in KeyError -> raise(ArgumentError, Exception.message(err))
      err             -> reraise(err, System.stacktrace)
    end
  end

  @doc """
  Build new channel representation from a channel id.
  """
  @spec new_from_id(Slack.t, String.t) :: __MODULE__.t | no_return()
  def new_from_id(slack, channel_id) do
    try do
      %__MODULE__{
        id: channel_id,
        name: Lookups.lookup_channel_name(channel_id, slack)
      }

    rescue
      _err in UndefinedFunctionError -> raise(ArgumentError, "No such channel: #{channel_id}")
      err -> reraise(err, System.stacktrace)
    end
  end
end
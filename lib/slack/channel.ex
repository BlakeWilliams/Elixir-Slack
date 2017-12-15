defmodule Slack.Channel do
  @moduledoc """
  Functions for interacting with channels in Slack.
  """
  alias Slack.Lookups

  defstruct [:id, :name]

  @doc """
  Returns a new `%Slack.Channel{}`.

  opts - order doesn't matter
    id - opaque id, as a string, of the channel
    name - human readable name of channel
  """
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
  Returns a new `%Slack.Channel()`.

  slack - a `%Slack.State{}` that is the current connection information
  channel_id - the opaque id, as a string, of the channel
  """
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
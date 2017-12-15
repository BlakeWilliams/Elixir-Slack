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
    with {:ok, id} <- get_arg(opts, :id),
         {:ok, name} <- get_arg(opts, :name)
    do
      %__MODULE__{
        id: id,
        name: name
      }

    else
      {:error, msg} -> raise(ArgumentError, msg)
      wat -> raise("unexpected value: #{inspect(wat)}")
    end
  end

  @doc """
  Returns a new `%Slack.Channel()`.

  slack - a `%Slack.State{}` that is the current connection information
  channel_id - the opaque id, as a string, of the channel
  """
  def new_from_id(slack, channel_id) do
    with {:ok, name} <- lookup_name(slack, channel_id)
    do
      {:ok, new(id: channel_id, name: name)}
    else
      e = {:error, ""<>_} -> e
      wat -> raise("unexpected value: #{inspect(wat)}")
    end
  end

  defp get_arg(keyword, key) do
    case Keyword.fetch(keyword, key) do
      r = {:ok, _} -> r
      :error -> {:error, "Missing argument: #{key}"}
    end
  end

  defp lookup_name(slack, channel_id) do
    try do
      {:ok, Lookups.lookup_channel_name(channel_id, slack)}
    rescue
      _err in UndefinedFunctionError -> {:error, "No such channel: #{channel_id}"}
      err -> reraise(err, System.stacktrace)
    end
  end

end
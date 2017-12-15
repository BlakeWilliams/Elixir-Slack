defmodule Slack.User do
  @moduledoc """
  Functions for interacting with users (and bots) in Slack.
  """
  alias Slack.Lookups

  defstruct [:id, :name]

  @doc """
  Returns a new `%Slack.User{}.

  opts - order doesn't matter
    id - opaque id, as a string, of the user
    name - human readable name of user

  Raises `%ArgumentError{}` if called w/o required option.
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
      {:error, message} -> raise(ArgumentError, message)
    end
  end

  @doc """
  Returns a `{:ok, %Slack.User{})` or `{:error, "" <> _}`.

  slack - a `%Slack.State{}` that is the current connection information
  user_id - opaque id, as a string, of the user
  """
  def new_from_id(slack, user_id) do
    with {:ok, name} <- lookup_name(slack, user_id)
    do
      {:ok, new(id: user_id, name: name)}

    else
      e = {:error, _} -> e
    end
  end

  defp get_arg(keyword, key) do
    case Keyword.fetch(keyword, key) do
      r = {:ok, _} -> r
      :error -> {:error, "Missing argument: #{key}"}
    end
  end

  defp lookup_name(slack, user_id) do
    try do
      {:ok, Lookups.lookup_user_name(user_id, slack)}
    rescue
      _err in UndefinedFunctionError -> {:error, "No such user: #{user_id}"}
      err -> reraise(err, System.stacktrace)
    end
  end
end

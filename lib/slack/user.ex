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
  Returns a new `%Slack.User{}`.

  slack - a `%Slack.State{}` that is the current connection information
  user_id - opaque id, as a string, of the user
  """
  def new_from_id(slack, user_id) do
    try do
      %__MODULE__{
        id: user_id,
        name: Lookups.lookup_user_name(user_id, slack)
      }

    rescue
      _err in UndefinedFunctionError -> raise(ArgumentError, "No such user: #{user_id}")
      err -> reraise(err, System.stacktrace)
    end
  end

end
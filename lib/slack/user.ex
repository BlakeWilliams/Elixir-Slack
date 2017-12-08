defmodule Slack.User do
  @moduledoc """
  Functions for interacting with users (and bots) in Slack.
  """
  alias Slack.Lookups

  @typedoc """
  Represents a user in slack.
  """
  @opaque t :: %__MODULE__{}
  defstruct [:id, :name]

  @doc """
  Build a new user representation.
  """
  @spec new([id: String.t, name: String.t]) :: __MODULE__.t
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
  Build new user representation from a user id.
  """
  @spec new_from_id(Slack.t, String.t) :: __MODULE__.t | no_return()
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
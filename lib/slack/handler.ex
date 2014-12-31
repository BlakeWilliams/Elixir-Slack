defmodule Slack.Handler do
  @moduledoc """
  A behavior for the Slack real time messaging API via websockets.
  """

  use Behaviour

  defcallback init(any, Slack.State.state) :: {:ok, any}

  defcallback handle_message(
    {:type, binary, map},
    Slack.State.state,
    any
  ) :: {:ok, any}
end

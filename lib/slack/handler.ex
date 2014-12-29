defmodule Slack.Handler do
  @moduledoc """
  A behavior for the Slack real time messaging API via websockets.
  """

  use Behaviour

  defcallback init(any ,:websocket_req.Req) :: {:ok, any}

  defcallback handle_message(
    {:type, binary, map},
    :websocket_req.Req,
    any
  ) :: {:ok, any}
end

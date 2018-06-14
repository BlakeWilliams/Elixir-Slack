defmodule Slack.Web.Client do
  @moduledoc """
  Defines a custom client for making calls to Slack Web API.
  """

  @type url :: String.t()
  @type form_body :: {:form, Keyword.t()}
  @type multipart_form_body :: {:multipart, nonempty_list(tuple())}
  @type body :: form_body() | multipart_form_body()

  @doc """
  Return value is passed directly to caller of generated Web API
  module/functions. Can be any term.
  """
  @callback post!(url :: url, body :: body) :: term()
end

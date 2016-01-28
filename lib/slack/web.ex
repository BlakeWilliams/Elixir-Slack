defmodule Slack.Web do

  @http_module Application.get_env(:slack, :http_module) || HTTPoison

  def http_module(), do: @http_module

end

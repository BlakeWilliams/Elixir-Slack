defmodule Slack.Web.DefaultClient do
  @moduledoc """
  Default http client used for all requests to Slack Web API.

  All Slack RPC method calls are delivered via post and are dangerous by
  default, raising on any HTTP response that doesn't contain a body field.

  Parsed body data is returned unwrapped to the caller.

  Additional error handling or response wrapping can be controlled as needed
  by configuring a custom client module.

  ```
  config :slack, :web_http_client, YourApp.CustomClient
  ```
  """

  @behaviour Slack.Web.Client

  @impl true
  def post!(url, body) do
    url
    |> HTTPoison.post!(body, [], opts())
    |> Map.fetch!(:body)
    |> Poison.Parser.parse!(%{})
  end

  defp opts do
    Application.get_env(:slack, :web_http_client_opts, [])
  end
end

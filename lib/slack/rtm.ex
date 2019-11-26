defmodule Slack.JsonDecodeError do
  @moduledoc false

  defexception [:reason, :string]

  def message(%Slack.JsonDecodeError{reason: reason, string: string}) do
    "Poison could not decode string for reason: `:#{reason}`, string given:\n#{string}"
  end
end

defmodule Slack.Rtm do
  @moduledoc false

  def start(token) do
    with url <- slack_url(token),
         headers <- [],
         options <- Application.get_env(:slack, :web_http_client_opts, []) do
      url
      |> HTTPoison.get(headers, options)
      |> handle_response()
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body}}) do
    case Poison.Parser.parse!(body, %{keys: :atoms}) do
      %{ok: true} = json ->
        {:ok, json}

      %{error: reason} ->
        {:error, "Slack API returned an error `#{reason}.\n Response: #{body}"}

      _ ->
        {:error, "Invalid RTM response"}
    end
  rescue
    error in Poison.ParseError ->
      %Poison.ParseError{pos: _, value: reason, rest: _} = error
      {:error, %Slack.JsonDecodeError{reason: reason, string: body}}
  end

  defp handle_response(error), do: error

  defp slack_url(token) do
    Application.get_env(:slack, :url, "https://slack.com") <>
      "/api/rtm.start?token=#{token}&batch_presence_aware=true&presence_sub=true"
  end
end

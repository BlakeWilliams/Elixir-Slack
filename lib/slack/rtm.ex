defmodule Poison.DecodeError do
  defexception [:reason, :string]

  def message(%Poison.DecodeError{reason: reason, string: string}) do
    "Poison could not decode string for reason: `:#{reason}`, string given:\n#{string}"
  end
end

defmodule Slack.Rtm do
  @moduledoc false

  def start(token) do
    slack_url(token)
    |> HTTPoison.get()
    |> handle_response()
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body}}) do
    case Poison.Parser.parse(body, keys: :atoms) do
      {:ok, %{ok: true} = json} -> {:ok, json}
      {:ok, %{error: reason}} -> {:error, "Slack API returned an error `#{reason}.\n Response: #{body}"}
      {:error, reason} -> {:error, %Poison.DecodeError{reason: reason, string: body}}
      _ -> {:error, "Invalid RTM response"}
    end
  end
  defp handle_response(error), do: error

  defp slack_url(token) do
    Application.get_env(:slack, :url, "https://slack.com") <> "/api/rtm.start?token=#{token}"
  end
end

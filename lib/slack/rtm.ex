defmodule Slack.Rtm do
  @moduledoc false
  @url "https://slack.com/api/rtm.start?token="

  def start(token, http \\ HTTPoison) do
    case http.get(@url <> token) do
      {:ok, response} ->
        json = JSX.decode!(response.body, [{:labels, :atom}])
        {:ok, json}
      {:error, reason} -> {:error, reason}
    end
  end
end

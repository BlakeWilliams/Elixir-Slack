defmodule Slack.Rtm do
  @moduledoc false
  @url "https://slack.com/api/rtm.start?token="

  def start(token) do
    case HTTPoison.get(@url <> token) do
      {:ok, response} ->
        json = JSX.decode!(response.body, [{:labels, :atom}])
        {:ok, json}
      {:error, reason} -> {:error, reason}
    end
  end
end

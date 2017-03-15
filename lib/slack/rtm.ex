defmodule Poison.DecodeError do
  defexception [:reason, :string]

  def message(%Poison.DecodeError{reason: reason, string: string}) do
    "Poison could not decode string for reason: `:#{reason}`, string given:\n#{string}"
  end
end

defmodule Slack.Rtm do
  @moduledoc false

  def start(token) do
    url = Application.get_env(:slack, :url, "https://slack.com") <> "/api/rtm.start?token="

    case HTTPoison.get(url <> token) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case Poison.Parser.parse(body, keys: :atoms) do
          {:ok, json}       -> {:ok, json}
          {:error, reason}  -> {:error, %Poison.DecodeError{reason: reason, string: body}}
        end
      {:error, reason} -> {:error, reason}
    end
  end
end

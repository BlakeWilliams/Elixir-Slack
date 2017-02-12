defmodule JSX.DecodeError do
  defexception [:reason, :string]

  def message(%JSX.DecodeError{reason: reason, string: string}) do
    "JSX could not decode string for reason: `:#{reason}`, string given:\n#{string}"
  end
end

defmodule Slack.Rtm do
  @moduledoc false

  def start(token) do
    url = Application.get_env(:slack, :url, "https://slack.com") <> "/api/rtm.start?token="

    case HTTPoison.get(url <> token) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case JSX.decode(body, [{:labels, :atom}]) do
          {:ok, json}       -> {:ok, json}
          {:error, reason}  -> {:error, %JSX.DecodeError{reason: reason, string: body}}
        end
      {:error, reason} -> {:error, reason}
    end
  end
end

defmodule JSX.DecodeError do
  defexception [:reason, :string]

  def message(%JSX.DecodeError{reason: reason, string: string}) do
    "JSX could not decode string for reason: `:#{reason}`, string given:\n#{string}"
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
    with {:ok, json} <- JSX.decode(body, [{:labels, :atom}]),
      %{ok: true} = json do
        {:ok, json}
    else
      {:error, reason} -> {:error, %JSX.DecodeError{reason: reason, string: body}}
      _ -> {:error, "Invalid RTM response"}
    end
  end

  defp handle_response({:error, _reason} = error), do: error

  defp slack_url(token) do
    Application.get_env(:slack, :url, "https://slack.com") <> "/api/rtm.start?token=#{token}"
  end

end

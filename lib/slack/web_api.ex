defmodule Slack.WebApi do
  @moduledoc """
  Provides access to Slack's Web API.
  """

  @doc """

  Returns a `{:ok, %{}}` or `{:error, ""<>_}`. The second element of
  the ok tuple is the parsed JSON response from the slack web API.

  slack - a `%Slack.State{}` that is the current connection information
  api_method - the name of the api method to call
  form_data - a keyword list of the form data to send
  """
  def form_post(slack, api_method, form_data) do
    url = "#{slack.slack_url}/api/#{api_method}"

    with full_form_data <- [{:token, slack.token} | form_data],
         {:ok, %{body: body}} <- HTTPoison.post(url, {:form, full_form_data}),
         {:ok, parsed} <- Poison.decode(body),
         %{"ok" => true} <- parsed
    do
      {:ok, parsed}

    else
      %{"ok" => false, "error" => err_code} -> {:error, "Slack rejected the request because #{err_code}"}
      e = {:error, ""<>_} -> e
      {:error, ex = %{__exception__: true}} -> {:error, Exception.message(ex)}
      wat -> raise("unexpected value: #{inspect(wat)}")
    end
  end

end
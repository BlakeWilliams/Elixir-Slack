defmodule Slack.WebApi do
  @moduledoc """
  Provides access to Slack's Web API.
  """

  @doc """
  Returns a parsed JSON response from the slack web API.

  slack - a `%Slack.State{}` that is the current connection information
  api_method - the name of the api method to call
  form_data - a keyword list of the form data to send

  Raises `%Slack.WebApi.Error{}` if the request is unsuccessful.
  """
  def form_post!(slack, api_method, form_data) do
    url = "#{slack.slack_url}/api/#{api_method}"

    %{body: body} = HTTPoison.post!(url, {:form, [{:token, slack.token} | form_data]})

    parsed = Poison.decode!(body)

    if Map.fetch!(parsed, "ok") do
      parsed
    else
      code = Map.get(parsed, "error", "code_missing")
      raise Slack.WebApi.Error, message: "#{code} failure POSTing to <#{url}> (form data: #{inspect(form_data)})", code: code
    end
  end

end

defmodule Slack.WebApi.Error do
  defexception [:message, :code]
end
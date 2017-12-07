defmodule Slack.WebApi do
  @moduledoc """
  Provides access to Slack's Web API.
  """

  @typedoc """
  Parsed JSON response body from API request.
  """
  @type parsed_response_body :: %{
    required(String.t) => nil
                          | boolean()
                          | float()
                          | String.t
                          | List.t
                          | parsed_response_body
  }

  @doc """
  Make a form encoded request to the web API.
  """
  @spec form_post!(Slack.t, String.t, Keyword.t) :: {:ok, parsed_response_body} | no_return()
  def form_post!(slack, api_method, form_data) do
    url = "#{slack.slack_url}/api/#{api_method}"

    %{body: body} = HTTPoison.post!(url, {:form, [{:token, slack.token} | form_data]})

    parsed = Poison.decode!(body)

    if Map.fetch!(parsed, "ok") do
      {:ok, parsed}
    else
      code = Map.get(parsed, "error", "code_missing")
      raise Slack.WebApi.Error, message: "#{code} failure POSTing to <#{url}> (form data: #{inspect(form_data)})", code: code
    end
  end

end

defmodule Slack.WebApi.Error do
  defexception [:message, :code]
end
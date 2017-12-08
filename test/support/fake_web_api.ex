defmodule Slack.FakeWebApi do
  def form_post!(_slack, api_method = "chat.getPermalink", form_data) do
    called(api_method, form_data)

    ts = Keyword.fetch!(form_data, :message_ts)
    channel_id = Keyword.fetch!(form_data, :channel)

    %{
      "ok" => true,
      "channel" => channel_id,
      "permalink" => ~s<http://example.com/archives/#{channel_id}/#{ts}>
    }
  end

  # call tracking
  def start_link do
    Agent.start_link(fn -> [] end, name: agent_name())
  end

  def called(api_method, form_data) do
    Agent.update(agent_name(), &[%{api_method: api_method, form_data: form_data} | &1])
  end

  def calls() do
    Agent.get(agent_name(), fn s -> s end)
  end

  defp agent_name() do
    String.to_atom("#{__MODULE__}_#{inspect(self())}")
  end
end

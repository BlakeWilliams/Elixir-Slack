defmodule Slack.FakeSlack do
  def start_link do
    Application.put_env(:slack, :url, "http://localhost:51345")

    Plug.Adapters.Cowboy.http(
      Slack.FakeSlack.Router,
      [],
      port: 51345,
      dispatch: dispatch()
    )
  end

  def stop do
    Plug.Adapters.Cowboy.shutdown(Slack.FakeSlack.Router)
  end

  defp dispatch do
    [
      {
        :_,
        [
          {"/ws", Slack.FakeSlack.Websocket, []},
          {:_, Plug.Adapters.Cowboy.Handler, {Slack.FakeSlack.Router, []}}
        ]
      }
    ]
  end
end

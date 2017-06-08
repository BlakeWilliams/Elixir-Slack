defmodule Slack.BotTest do
  use ExUnit.Case

  defmodule Bot do
    use Slack
  end

  @rtm %{
    url: "http://example.com",
    self: %{name: "fake"},
    team: %{name: "Foo"},
    bots: [%{id: "123"}],
    channels: [%{id: "123"}],
    groups: [%{id: "123"}],
    users: [%{id: "123"}],
    ims: [%{id: "123"}]
  }

  test "init formats rtm results properly" do
    {:reconnect, %{slack: slack, bot_handler: bot_handler}}
      = Slack.Bot.init(%{
          bot_handler: Bot,
          rtm: @rtm,
          client: FakeWebsocketClient,
          token: "ABC",
          initial_state: nil,
        })

    assert bot_handler == Bot
    assert slack.me.name == "fake"
    assert slack.team.name == "Foo"
    assert slack.bots     == %{"123" => %{id: "123"}}
    assert slack.channels == %{"123" => %{id: "123"}}
    assert slack.groups   == %{"123" => %{id: "123"}}
    assert slack.users    == %{"123" => %{id: "123"}}
    assert slack.ims      == %{"123" => %{id: "123"}}
  end

  defmodule Stubs.Slack.Rtm do
    def start(_token) do
      {:ok, %{url: "http://www.example.com"}}
    end
  end

  defmodule Stubs.Slack.WebsocketClient do
    def start_link(_url, _module, _state, _options) do
      {:ok, self()}
    end
  end

  test "can configure the RTM module" do
    Application.put_env(:slack, :rtm_module, Stubs.Slack.Rtm)
    assert {:ok, _pid} = Slack.Bot.start_link(Bot, %{}, "token", %{client: Stubs.Slack.WebsocketClient})
  end
end

defmodule Slack.BotTest do
  use ExUnit.Case

  defmodule Bot do
    use Slack
  end

  test "init formats rtm results properly" do
    rtm = %{
      self: %{name: "fake"},
      team: %{name: "Foo"},
      bots: [%{id: "123"}],
      channels: [%{id: "123"}],
      groups: [%{id: "123"}],
      users: [%{id: "123"}],
      ims: [%{id: "123"}]
    }

    {:reconnect, %{slack: slack, bot_handler: bot_handler}}
      = Slack.Bot.init(%{
          bot_handler: Bot,
          rtm: rtm,
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
end

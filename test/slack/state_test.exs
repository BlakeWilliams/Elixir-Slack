defmodule Slack.StateTest do
  use ExUnit.Case

  test "new returns a state with users and channels parsed" do
    channels = [%{id: "1"}, %{id: "2"}]
    users = [%{id: "3"}, %{id: "4"}]
    me = %{id: "1", name: "Blake"}

    fake_rtm_response = %{channels: channels, self: me, users: users}

    state = Slack.State.new(nil, fake_rtm_response)

    assert Slack.State.channels(state) == %{"1": %{id: "1"}, "2": %{id: "2"}}
    assert Slack.State.users(state) == %{"3": %{id: "3"}, "4": %{id: "4"}}
  end
end

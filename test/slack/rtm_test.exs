# defmodule Slack.SendsTest do
#   use ExUnit.Case
#   alias Slack.RTM
# 
#   defmodule FakeWebsocketClient do
#     def send({:text, json}, socket) do
#       {json, socket}
#     end
#   end
# 
#   test "non-json responses like error messages don't crash app" do
#     Slack.Rtm.start(token)
#   end
# end

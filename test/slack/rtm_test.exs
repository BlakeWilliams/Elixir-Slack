defmodule Slack.RtmTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "it fetches the response from the proper location" do
    assert capture_io(fn ->
      {:ok, %{success: true}} = Slack.Rtm.start("abc123", FakeHTTP)
    end) == "https://slack.com/api/rtm.start?token=abc123"
  end
end

defmodule FakeHTTP do
  def get(url) do
    IO.write url
    {:ok, %{body: ~s/{"success": true}/}}
  end
end

defmodule Slack.WebTest do
  use ExUnit.Case
  alias Slack.Web

  @slack %{token: "token"}

  test "successful open im" do
    FakeHttp.set_callback success(~s({"ok": true, "channel": {"id": "456"}}))
    assert {:ok, %{id: "456"}} = Web.IM.open("123", @slack)
  end

  test "failure open im" do
    FakeHttp.set_callback success(~s({"ok": false, "error": "broken"}))
    assert {:error, "broken"} = Web.IM.open("123", @slack)
  end

  test "error open im" do
    FakeHttp.set_callback error()
    assert {:error, "broken"} = Web.IM.open("123", @slack)
  end

  test "successful close im" do
    FakeHttp.set_callback success(~s({"ok": true}))
    assert :ok = Web.IM.close("123", @slack)
  end

  test "failure close im" do
    FakeHttp.set_callback success(~s({"ok": false, "error": "broken"}))
    assert {:error, "broken"} = Web.IM.close("123", @slack)
  end

  test "error close im" do
    FakeHttp.set_callback error()
    assert {:error, "broken"} = Web.IM.close("123", @slack)
  end

  test "successful im list" do
    FakeHttp.set_callback success(~s({"ok": true, "ims": []}))
    assert {:ok, []} = Web.IM.list(@slack)
  end

  test "failure im list" do
    FakeHttp.set_callback success(~s({"ok": false, "error": "broken"}))
    assert {:error, "broken"} = Web.IM.list(@slack)
  end

  test "error im list" do
    FakeHttp.set_callback error()
    assert {:error, "broken"} = Web.IM.list(@slack)
  end

  def success(response) do
    fn(_url) ->
      {:ok, %{body: response}}
    end
  end

  def error() do
    fn(_url) ->
      {:error, "broken"}
    end
  end

end

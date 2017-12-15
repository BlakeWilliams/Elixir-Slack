defmodule Slack.WebApiTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  describe "form_post/3" do
    test "posts to correct URL", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        assert "/api/test.method" == conn.request_path
        assert "POST" == conn.method
        Plug.Conn.resp(conn, 200, ~s<{ "ok": true }>)
      end

      Slack.WebApi.form_post(slack(bypass), "test.method", [some: "thing"])
    end

    test "returns parsed response body", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 200, ~s<{ "ok": true }>)
      end

      assert {:ok, %{"ok" => true }} = Slack.WebApi.form_post(slack(bypass), "test.method", [some: "thing"])
    end

    test "raises exception on non-ok response", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 400, ~s<{ "ok": false, "error": "my-special-error"}>)
      end

      assert {:error, ""<>_} =
        Slack.WebApi.form_post(slack(bypass), "test.method", [some: "thing"])
    end

    test "puts code in error tuple", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 400, ~s<{ "ok": false, "error": "my-special-error"}>)
      end

      {:error, msg} = Slack.WebApi.form_post(slack(bypass), "test.method", [some: "thing"])

      assert Regex.match?(~r/my-special-error/, msg)
    end
  end


  # background & support
  # ----

  defp slack(bypass) do
    %Slack.State{
      token: "xoxa-testtoken",
      slack_url: "http://localhost:#{bypass.port}"
    }
  end
end
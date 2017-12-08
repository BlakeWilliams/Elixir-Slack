defmodule Slack.WebApiTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  describe "form_post!/3" do
    test "posts to correct URL", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        assert "/api/test.method" == conn.request_path
        assert "POST" == conn.method
        Plug.Conn.resp(conn, 200, ~s<{ "ok": true }>)
      end

      Slack.WebApi.form_post!(slack(bypass), "test.method", [some: "thing"])
    end

    test "returns parsed response body", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 200, ~s<{ "ok": true }>)
      end

      assert {:ok, %{"ok" => true }} == Slack.WebApi.form_post!(slack(bypass), "test.method", [some: "thing"])
    end

    test "raises exception on non-ok response", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 400, ~s<{ "ok": false }>)
      end

      assert_raise(
        Slack.WebApi.Error,
        fn ->
          Slack.WebApi.form_post!(slack(bypass), "test.method", [some: "thing"])
        end
      )
    end

    test "puts code in exception on non-ok response", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 400, ~s<{ "ok": false, "error": "my-special-error"}>)
      end
      exception = catch_exception(fn ->
        Slack.WebApi.form_post!(slack(bypass), "test.method", [some: "thing"])
      end)

      assert "my-special-error" == exception.code
    end
  end


  # background & support
  # ----

  defp catch_exception(fun) do
    try do
      fun.()
    rescue
      err -> err
    end
  end

  defp slack(bypass) do
    %Slack.State{
      token: "xoxa-testtoken",
      slack_url: "http://localhost:#{bypass.port}"
    }
  end
end
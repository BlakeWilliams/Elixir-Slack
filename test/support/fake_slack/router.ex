defmodule Slack.FakeSlack.Router do
  use Plug.Router
  import Plug.Conn

  plug(:match)
  plug(:dispatch)

  get "/api/rtm.start" do
    conn = fetch_query_params(conn)

    pid = Application.get_env(:slack, :test_pid)
    send(pid, {:token, conn.query_params["token"]})

    response = ~S(
      {
        "ok": true,
        "url": "ws://localhost:51345/ws",
        "self": { "id": "U0123abcd", "name": "bot" },
        "team": { "id": "T4567abcd", "name": "Example Team" },
        "bots": [{ "id": "U0123abcd", "name": "bot" }],
        "channels": [],
        "groups": [],
        "users": [],
        "ims": []
      }
    )

    send_resp(conn, 200, response)
  end

  get "/api/rtm.connect" do
    conn = fetch_query_params(conn)

    pid = Application.get_env(:slack, :test_pid)
    send(pid, {:token, conn.query_params["token"]})

    response = ~S(
      {
        "ok": true,
        "url": "ws://localhost:51345/ws",
        "self": { "id": "U0123abcd", "name": "bot" },
        "team": { "id": "T4567abcd", "name": "Example Team" },
        "channels": [],
        "groups": [],
        "users": [],
        "ims": []
      }
    )

    send_resp(conn, 200, response)
  end
end

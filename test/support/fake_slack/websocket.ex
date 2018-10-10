defmodule Slack.FakeSlack.Websocket do
  @behaviour :cowboy_websocket_handler

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  @activity_timeout 5000

  def websocket_init(_type, req, _opts) do
    state = %{}

    pid = Application.get_env(:slack, :test_pid)
    send(pid, {:websocket_connected, self()})

    {:ok, req, state, @activity_timeout}
  end

  def websocket_handle({:text, "ping"}, req, state) do
    {:reply, {:text, "pong"}, req, state}
  end

  def websocket_handle({:text, message}, req, state) do
    pid = Application.get_env(:slack, :test_pid)
    send(pid, {:bot_message, Poison.decode!(message)})

    {:ok, req, state}
  end

  def websocket_info(message, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_terminate(_reason, _req, _state) do
    :ok
  end
end

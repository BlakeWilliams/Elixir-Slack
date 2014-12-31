defmodule Slack.Socket do
  @behaviour :websocket_client_handler
  @moduledoc false

  def init(bootstrap = %{handler: handler, state: state}, socket) do
    socket_state = Slack.State.new(socket, bootstrap.channels, bootstrap.users)
    {:ok, state} = handler.init(state, socket_state)

    state = %{
      handler: handler,
      handler_state: state,
      socket_state: socket_state
    }

    {:ok, state}
  end

  def websocket_handle({:text, message}, _connection, state) do
    json = JSX.decode!(message, [{:labels, :atom}])

    if Map.has_key?(json, :type) do
      {:ok, new_state} = send_handler_message(json, state)

      state = Map.put(state, :handler_state, new_state)
    end

    {:ok, state}
  end

  def websocket_handle({:ping, data}, _connection, state) do
    {:reply, {:pong, data}, state}
  end

  def websocket_info(:start, _connection, state) do
    {:ok, state}
  end

  def websocket_terminate(_reason, _connection, _state) do
    :ok
  end

  defp send_handler_message(json, state) do
    state.handler.handle_message(
      {:type, json.type, json},
      state.socket_state,
      state.handler_state
    )
  end
end

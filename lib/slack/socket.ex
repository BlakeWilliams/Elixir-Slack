defmodule Slack.Socket do
  @behaviour :websocket_client_handler

  def init(handler, socket) do
    {:ok, state} = handler.init(socket)

    {:ok, %{handler: handler, handler_state: state}}
  end

  def websocket_handle({:text, message}, socket, state) do
    json = JSX.decode!(message, [{:labels, :atom}])

    if Map.has_key?(json, :type) do
      {:ok, new_state } = send_handler_message(json, socket, state)
      Map.put(state, :handler_state, new_state)
    end

    {:ok, state}
  end

  def websocket_handle({:ping, data}, _state, state) do
    {:reply, {:pong, data}, state}
  end

  def websocket_info(:start, _socket, state) do
    {:ok, state}
  end

  def websocket_terminate(_reason, _socket, _state) do
    :ok
  end

  defp send_handler_message(json, socket, state) do
    handler = state.handler
    state = state.handler_state

    handler.handle_message({:type, json.type, json}, socket, state)
  end
end

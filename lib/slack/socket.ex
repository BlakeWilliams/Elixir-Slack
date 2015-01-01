defmodule Slack.Socket do
  @behaviour :websocket_client_handler
  @moduledoc false

  def init(bootstrap = %{module: module, initial_state: initial_state}, socket) do
    slack_state = Slack.State.new(socket, bootstrap.channels, bootstrap.users)
    {:ok, module_state} = module.init(initial_state, slack_state)

    state = %{
      module: module,
      module_state: module_state,
      slack_state: initial_state
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
    state.module.handle_message(
      {:type, json.type, json},
      state.slack_state,
      state.module_state
    )
  end
end

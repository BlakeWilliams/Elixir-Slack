defmodule Slack.Bot do
  require Logger

  @behaviour :websocket_client

  @moduledoc """
  This module is used to spawn bots and is used to manage the connection to Slack
  while delegating events to the specified bot module.
  """

  @doc """
  Connects to Slack and delegates events to `bot_handler`.

  ## Options

  * `keepalive` - How long to wait for the connection to respond before the client kills the connection.
  * `name` - registers a name for the process with the given atom

  ## Example

  {:ok, pid} = Slack.Bot.start_link(MyBot, [1,2,3], "abc-123", %{name: :slack_bot})

  :sys.get_state(:slack_bot)

  """
  def start_link(bot_handler, initial_state, token, options \\ %{}) do
    options =
      Map.merge(
        %{
          client: :websocket_client,
          keepalive: 10_000,
          name: nil
        },
        options
      )

    rtm_module = Application.get_env(:slack, :rtm_module, Slack.Rtm)

    case rtm_module.start(token) do
      {:ok, rtm} ->
        state = %{
          bot_handler: bot_handler,
          rtm: rtm,
          client: options.client,
          token: token,
          initial_state: initial_state
        }

        url = String.to_charlist(state.rtm.url)

        {:ok, pid} =
          options.client.start_link(url, __MODULE__, state, keepalive: options.keepalive)

        if options.name != nil do
          Process.register(pid, options.name)
        end

        {:ok, pid}

      {:error, %HTTPoison.Error{reason: :connect_timeout}} ->
        {:error, "Timed out while connecting to the Slack RTM API"}

      {:error, %HTTPoison.Error{reason: :nxdomain}} ->
        {:error, "Could not connect to the Slack RTM API"}

      {:error, %Slack.JsonDecodeError{string: "You are sending too many requests. Please relax."}} ->
        {:error, "Sent too many connection requests at once to the Slack RTM API."}

      {:error, error} ->
        {:error, error}
    end
  end

  # websocket_client API

  @doc false
  @since "0.19.0"
  @deprecated """
  `rtm.start` is replaced with `rtm.connect` and will no longer receive bots, channels, groups, users, or IMs.
  In future versions these will no longer be provided on initialization.
  """
  def init(%{
        bot_handler: bot_handler,
        rtm: rtm,
        client: client,
        token: token,
        initial_state: initial_state
      }) do
    slack = %Slack.State{
      process: self(),
      client: client,
      token: token,
      me: rtm.self,
      team: rtm.team,
      bots: rtm_list_to_map(rtm.bots),
      channels: rtm_list_to_map(rtm.channels),
      groups: rtm_list_to_map(rtm.groups),
      users: rtm_list_to_map(rtm.users),
      ims: rtm_list_to_map(rtm.ims)
    }

    {:reconnect, %{slack: slack, bot_handler: bot_handler, process_state: initial_state}}
  end

  @doc false
  def onconnect(
        _websocket_request,
        %{slack: slack, process_state: process_state, bot_handler: bot_handler} = state
      ) do
    {:ok, new_process_state} = bot_handler.handle_connect(slack, process_state)
    {:ok, %{state | process_state: new_process_state}}
  end

  @doc false
  def ondisconnect({:error, :keepalive_timeout}, state) do
    {:reconnect, state}
  end

  def ondisconnect(
        reason,
        %{slack: slack, process_state: process_state, bot_handler: bot_handler} = state
      ) do
    try do
      bot_handler.handle_close(reason, slack, process_state)
      {:close, reason, state}
    rescue
      e ->
        handle_exception(e)
        {:close, reason, state}
    end
  end

  @doc false
  def websocket_info(
        message,
        _connection,
        %{slack: slack, process_state: process_state, bot_handler: bot_handler} = state
      ) do
    try do
      {:ok, new_process_state} = bot_handler.handle_info(message, slack, process_state)
      {:ok, %{state | process_state: new_process_state}}
    rescue
      e ->
        handle_exception(e)
        {:ok, state}
    end
  end

  @doc false
  def websocket_terminate(_reason, _conn, _state), do: :ok

  @doc false
  def websocket_handle(
        {:text, message},
        _conn,
        %{slack: slack, process_state: process_state, bot_handler: bot_handler} = state
      ) do
    message = prepare_message(message)

    updated_slack =
      if Map.has_key?(message, :type) do
        Slack.State.update(message, slack)
      else
        slack
      end

    new_process_state =
      if Map.has_key?(message, :type) do
        try do
          {:ok, new_process_state} = bot_handler.handle_event(message, slack, process_state)
          new_process_state
        rescue
          e -> handle_exception(e)
        end
      else
        process_state
      end

    {:ok, %{state | slack: updated_slack, process_state: new_process_state}}
  end

  def websocket_handle(_, _conn, state), do: {:ok, state}

  defp rtm_list_to_map(list) do
    Enum.reduce(list, %{}, fn item, map ->
      Map.put(map, item.id, item)
    end)
  end

  defp prepare_message(binstring) do
    binstring
    |> :binary.split(<<0>>)
    |> List.first()
    |> Poison.Parser.parse!(%{keys: :atoms})
  end

  defp handle_exception(e) do
    message = Exception.message(e)
    Logger.error(message)
    System.stacktrace() |> Exception.format_stacktrace() |> Logger.error()
    raise message
  end
end

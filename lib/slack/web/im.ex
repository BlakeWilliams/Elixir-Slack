defmodule Slack.Web.IM do
  @http_module Slack.Web.http_module

  @open_url "https://slack.com/api/im.open?token="
  @doc """
  Open a direct message with another user. Checks if the IM is already opened
  and will return that channel if it is.
  """
  @spec open(binary, map) :: {:ok, binary} | {:error, binary}
  def open(user, slack) do
    cond do
      # Check if already available
      slack[:ims][user] && slack[:ims][user][:is_open] -> {:ok, slack[:ims][user]}
      true ->
        # Will cause an `im_created` event to be broadcast which updates slack state
        case @http_module.get(@open_url <> slack.token <> "&user=" <> user) do
          {:ok, response} ->
            json = JSX.decode!(response.body, [{:labels, :atom}])
            (json[:ok] && {:ok, json[:channel]}) || {:error, json[:error]}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  @close_url "https://slack.com/api/im.close?token="
  @doc """
  Closes a direct message with another user.
  """
  @spec close(binary, map) :: :ok | {:error, binary}
  def close(channel, slack) do
    # Will cause an `im_close` event to be broadcast which updates slack state
    case @http_module.get(@close_url <> slack.token <> "&channel=" <> channel) do
      {:ok, response} ->
        json = JSX.decode!(response.body, [{:labels, :atom}])
        (json[:ok] && :ok) || {:error, json[:error]}
      {:error, reason} -> {:error, reason}
    end
  end

  @list_url "https://slack.com/api/im.list?token="
  @doc """
  Gathers the new list of ims
  """
  @spec list(map) :: {:ok, list} | {:error, binary}
  def list(slack) do
    case @http_module.get(@list_url <> slack.token) do
      {:ok, response} ->
        json = JSX.decode!(response.body, [{:labels, :atom}])
        (json[:ok] && {:ok, json[:ims]}) || {:error, json[:error]}
      {:error, reason} -> {:error, reason}
    end
  end
end

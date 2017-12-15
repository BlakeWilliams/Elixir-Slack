defmodule Slack.Message do
  @moduledoc """
  Functions for creating and manipulating messages in slack.
  """

  alias Slack.{Channel, User}

  @web_api Application.get_env(:slack, :web_api, Slack.WebApi)

  defstruct [:channel, :sender, :ts, :text]

  @doc """
  Returns a new `%Slack.Message{}` representation a message.

  opts - order doesn't matter
    channel - a `%Slack.Channel{}` representing the channel in which this message
              is posted
    sender - a `%Slack.User{}` representing the user who posted this message
    ts - an opaque id of message as a string
    text - the message as a string
  """
  def new(opts) do
    with {:ok, channel} <- get_arg(opts, :channel),
         {:ok, sender} <- get_arg(opts, :sender),
         {:ok, ts} <- get_arg(opts, :ts),
         {:ok, text} <- get_arg(opts, :text)
    do
      %__MODULE__{
        channel: channel,
        sender:  sender,
        ts:      ts,
        text:    text
      }
    else
      {:error, msg} -> raise(ArgumentError, msg)
      wat -> raise("unexpected value: #{inspect(wat)}")
    end
  end

  @doc """
  Returns a new `%Slack.Message{}` representation a message.

  slack - a `%Slack.State{}` that is the current connection information
  msg_event - a map containing the `message` event to interpret
  """
  def new_from_event(slack, event) do
    with {:ok, channel_id} <- get_arg(event, :channel),
         {:ok, channel} <- Channel.new_from_id(slack, channel_id),
         {:ok, user_id} <- get_arg(event, :user),
         {:ok, sender} <- User.new_from_id(slack, user_id),
         {:ok, ts} <- get_arg(event, :ts),
         {:ok, text} <- get_arg(event, :text)
    do
      {:ok, %__MODULE__{
          channel: channel,
          sender:  sender,
          ts:      ts,
          text:    text
       }
      }

    else
      {:error, msg} -> raise(ArgumentError, msg)
      wat -> raise("unexpected value: #{inspect(wat)}")
    end

  end

  @doc """
  Returns a `{:ok, ""<>_}` or `{:error, ""<>_}`.

  slack - a `%Slack.State{}` that is the current connection information
  message - a `%Slack.Message{}` whose permalink you want
  """
  def permalink(slack, message) do
    with {:ok, resp_body} <- @web_api.form_post(
           slack,
           "chat.getPermalink",
           message_ts: message.ts,
           channel: message.channel.id
         ),
         %{"permalink" => url} <- resp_body
    do
      {:ok, url}
    else
      e = {:error, ""<>_} -> e
      wat -> raise("Unexpected value: #{inspect(wat)}")
    end
  end

  defp get_arg(keyword, key) do
    case Access.fetch(keyword, key) do
      r = {:ok, _} -> r
      :error -> {:error, "Missing argument: #{key}"}
    end
  end
end
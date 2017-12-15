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
    try do
      %__MODULE__{
        channel: Keyword.fetch!(opts, :channel),
        sender:  Keyword.fetch!(opts, :sender),
        ts:      Keyword.fetch!(opts, :ts),
        text:    Keyword.fetch!(opts, :text)
      }

    rescue
      err in KeyError -> raise(ArgumentError, Exception.message(err))
      err             -> reraise(err, System.stacktrace)
    end
  end

  @doc """
  Returns a new `%Slack.Message{}` representation a message.

  slack - a `%Slack.State{}` that is the current connection information
  msg_event - a map containing the `message` event to interpret
  """
  def new_from_event(slack, event) do
    channel = Channel.new_from_id(slack, Map.fetch!(event, :channel))
    sender  = User.new_from_id(slack, Map.fetch!(event, :user))

    %__MODULE__{
      channel: channel,
      sender:  sender,
      ts:      Map.fetch!(event, :ts),
      text:    Map.fetch!(event, :text)
    }
  end

  @doc """
  Returns a permalink, as a string, for the message.

  slack - a `%Slack.State{}` that is the current connection information
  message - a `%Slack.Message{}` whose permalink you want
  """
  def permalink(slack, message) do
    resp_body = @web_api.form_post!(
      slack,
      "chat.getPermalink",
      message_ts: message.ts,
      channel: message.channel.id
    )

    Map.fetch!(resp_body, "permalink")
  end
end
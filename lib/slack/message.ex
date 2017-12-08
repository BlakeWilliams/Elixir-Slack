defmodule Slack.Message do
  @moduledoc """
  Functions for creating and manipulating messages in slack.
  """

  alias Slack.{Channel, User}

  @web_api Application.get_env(:slack, :web_api, Slack.WebApi)

  @typedoc """
  Represents a single message in slack.
  """
  @opaque t :: %__MODULE__{}
  defstruct [:channel, :sender, :ts, :text]

  @typep msg_event :: %{
    channel: String.t,
    user:    String.t,
    ts:      String.t,
    text:    String.t
  }

  @doc """
  Build a new message representation.
  """
  @spec new([channel: Channel.t, sender: User.t, ts: String.t, text: String.t]) :: __MODULE__.t
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
  Build a new message representation from a parsed `message` event.
  """
  @spec new_from_event(Slack.t, msg_event) :: __MODULE__.t
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
  Returns a permalink for the message.
  """
  @spec permalink(Slack.t, __MODULE__.t) :: String.t
  def permalink(slack, message) do
    {:ok, resp_body} = @web_api.form_post!(
      slack,
      "chat.getPermalink",
      message_ts: message.ts,
      channel: message.channel.id
    )

    Map.fetch!(resp_body, "permalink")
  end
end
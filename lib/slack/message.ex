defmodule Slack.Message do
  @moduledoc """
  This module contains functions to work with Slack Messages.

  Read more about it in Slack Official documentation:
    * https://api.slack.com/reference/messaging/payload
  """

  @typedoc """
  Defines a Slack Message data structure. You can read more about the keys from
  the official documentation.
  """
  @type t :: %__MODULE__{}

  defstruct [
    :text,
    :blocks,
    :attachments,
    :thread_ts,
    :mrkdwn
  ]

  @doc """
  Creates a Slack Message struct.

      iex> Slack.Message.new(%{ text: "Hello, World" })
      %Slack.Message{
        attachments: nil,
        blocks: nil,
        mrkdwn: nil,
        text: "Hello, World",
        thread_ts: nil
      }
  """
  @spec new(map()) :: t()
  def new(params \\ %{}) do
    struct(__MODULE__, params)
  end
end

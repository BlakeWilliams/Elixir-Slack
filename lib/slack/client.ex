defmodule Slack.Client do
  
  defstruct [
    socket: nil,
    client: nil,
    token:  nil,
    me:     nil,
    team:   nil,
    bots:     %{},
    channels: %{},
    groups:   %{},
    users:    %{},
    ims:      %{},
  ]
    
  @behaviour Access

  defdelegate fetch(slack, key),                    to: Map
  defdelegate get(slack, key),                      to: Map
  defdelegate get(slack, key, default),             to: Map
  defdelegate get_and_update(slack, key, function), to: Map
  
end
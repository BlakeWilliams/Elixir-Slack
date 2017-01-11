defmodule Slack.Web.DocumentationTest do
  use ExUnit.Case
  alias Slack.Web.Documentation

  test "it returns a proper keyword list" do
    doc = %Documentation{required_params: [:channel, :text]}

    argument_value_keyword_list = Documentation.arguments_with_values(doc)
    assert argument_value_keyword_list === [text: {:text, [], nil}, channel: {:channel, [], nil}]
  end
end

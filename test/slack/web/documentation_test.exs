defmodule Slack.Web.DocumentationTest do
  use ExUnit.Case
  alias Slack.Web.Documentation

  test "it returns a proper keyword list" do
    doc = %Documentation{required_params: [:channel, :text]}

    argument_value_keyword_list = Documentation.arguments_with_values(doc)
    assert argument_value_keyword_list === [text: {:text, [], nil}, channel: {:channel, [], nil}]
  end

  describe "new/2" do
    test "takes a documentation and filename, returns a module & function description" do
      file_content = %{
        "desc" => "Gets information about the current team.",
        "args" => %{},
        "errors" => %{}
      }

      doc = Documentation.new(file_content, "team.info.json")

      assert doc.module == "team"
      assert doc.endpoint == "team.info"
      assert doc.function == :info
      assert doc.desc == "Gets information about the current team."
      assert doc.required_params == []
      assert doc.optional_params == []
      assert doc.errors == %{}
      assert doc.raw == file_content

      module_functions = Slack.Web.Team.__info__(:functions)

      assert {:info, 0} in module_functions
      assert {:info, 1} in module_functions
    end

    test "generates function params based on required arguments from json" do
      file_content =
        "#{__DIR__}/../../../lib/slack/web/docs/conversations.replies.json"
        |> File.read!()
        |> Jason.decode!()

      doc = Documentation.new(file_content, "conversations.replies.json")

      assert doc.module == "conversations"
      assert doc.endpoint == "conversations.replies"
      assert doc.function == :replies

      module_functions = Slack.Web.Conversations.__info__(:functions)

      required_args_count = Enum.count(doc.required_params)

      # Without optional arguments
      assert {:replies, required_args_count} in module_functions

      # With optional arguments
      assert {:replies, required_args_count + 1} in module_functions
    end

    test "filters out required `:token` argument" do
      file_content =
        "#{__DIR__}/../../../lib/slack/web/docs/chat.postMessage.json"
        |> File.read!()
        |> Jason.decode!()

      doc = Documentation.new(file_content, "chat.postMessage.json")

      refute :token in doc.required_params,
             "required params contains `:token`, but this should be ignored"
    end

    test "accepts versioned endpoints" do
      file_content =
        "#{__DIR__}/../../../lib/slack/web/docs/oauth.v2.access.json"
        |> File.read!()
        |> Jason.decode!(%{})

      doc = Documentation.new(file_content, "oauth.v2.access.json")

      assert doc.module == "oauth.v2"
      assert doc.endpoint == "oauth.v2.access"
      assert doc.function == :access

      module_functions = Slack.Web.Oauth.V2.__info__(:functions)

      assert {:access, 0} in module_functions
      assert {:access, 1} in module_functions
    end
  end
end

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

    test "accepts versioned endpoints" do
      file_content =
        "#{__DIR__}/../../../lib/slack/web/docs/oauth.v2.access.json"
        |> File.read!()
        |> Poison.Parser.parse!(%{})

      doc = Documentation.new(file_content, "oauth.v2.access.json")

      assert doc.module == "oauth.v2"
      assert doc.endpoint == "oauth.v2.access"
      assert doc.function == :access

      module_functions = Slack.Web.Oauth.V2.__info__(:functions)

      assert {:access, 3} in module_functions
      assert {:access, 4} in module_functions
    end
  end
end

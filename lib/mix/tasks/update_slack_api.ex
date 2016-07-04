defmodule Mix.Tasks.UpdateSlackApi do
  use Mix.Task
  @dir System.tmp_dir

  def run(_) do
    try do
      System.cmd("git", ["clone", "https://github.com/slackhq/slack-api-docs", "#{@dir}/slack-api-docs"])
      files
      |> filter_json
      |> copy_files
    after
      System.cmd("rm", ["-rf", "#{@dir}/slack-api-docs"])
    end
  end

  defp files do
    File.ls!("#{@dir}slack-api-docs/methods")
  end

  defp filter_json(files) do
    Enum.filter(files, fn(file) ->
      String.ends_with?(file, "json")
    end)
  end

  defp copy_files(files) do
    File.mkdir_p!("lib/slack/web/docs")
    Enum.map(files, fn(file) ->
      origin = "#{@dir}slack-api-docs/methods/#{file}"
      dest = "lib/slack/web/docs/#{file}"
      File.cp!(origin, dest)
    end)
  end
end

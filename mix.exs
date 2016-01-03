defmodule Slack.Mixfile do
  use Mix.Project

  def project do
    [app: :slack,
     version: "0.3.0",
     elixir: "~> 1.0",
     name: "Slack",
     deps: deps,
     docs: docs,
     source_url: "https://github.com/BlakeWilliams/Elixir-Slack",
     description: "A Slack Real Time Messaging API client.",
     package: package]
  end

  def application do
    [applications: [:logger, :httpoison, :hackney, :exjsx]]
  end

  defp deps do
    [{:httpoison, "~> 0.8.0"},
     {:exjsx, "~> 3.1.0"},
     {:websocket_client, github: "jeremyong/websocket_client"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.6", only: :dev}]
  end

  def docs do
    [{:main, Slack}]
  end

  defp package do
    %{maintainers: ["Blake Williams"],
      licenses: ["MIT"],
      links: %{
        "Github": "https://github.com/BlakeWilliams/Elixir-Slack",
        "Documentation": "http://hexdocs.pm/slack/"}}
  end
end

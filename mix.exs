defmodule ExSlack.Mixfile do
  use Mix.Project

  def project do
    [app: :exslack,
     version: "0.0.1",
     elixir: "~> 1.0",
     name: "Slack",
     source_url: "https://github.com/BlakeWilliams/Elixir-Slack",
     deps: deps,
     docs: docs]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [{:httpoison, "~> 0.5.0"},
     {:exjsx, "~> 3.1.0"},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.6", only: :dev}]
  end

  def docs do
    [{:main, Slack}]
  end
end

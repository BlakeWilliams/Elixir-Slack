defmodule Slack.Mixfile do
  use Mix.Project

  def project do
    [app: :slack,
     version: "0.11.1",
     elixir: "~> 1.2",
     name: "Slack",
     deps: deps(),
     docs: docs(),
     source_url: "https://github.com/BlakeWilliams/Elixir-Slack",
     description: "A Slack Real Time Messaging API client.",
     package: package()]
  end

  def application do
    [applications: [:logger, :httpoison, :hackney, :crypto, :websocket_client]]
  end

  defp deps do
    [{:httpoison, "~> 0.11"},
     {:websocket_client, "~> 1.1"},
     {:poison, "~> 3.1"},
     {:earmark, "~> 0.2", only: :dev},
     {:ex_doc, "~> 0.12", only: :dev},
     {:credo, "~> 0.7", only: [:dev, :test]}
   ]
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

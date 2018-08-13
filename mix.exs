defmodule Slack.Mixfile do
  use Mix.Project

  def project do
    [app: :slack,
     version: "0.15.0",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     name: "Slack",
     deps: deps(),
     docs: docs(),
     source_url: "https://github.com/BlakeWilliams/Elixir-Slack",
     description: "A Slack Real Time Messaging API client.",
     package: package()]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  def application do
    [applications: [:logger, :httpoison, :hackney, :crypto, :websocket_client]]
  end

  defp deps do
    [{:httpoison, "~> 1.2"},
     {:websocket_client, "~> 1.2.4"},
     {:poison, "~> 3.0"},
     {:earmark, "~> 0.2.0", only: :dev},
     {:ex_doc, "~> 0.12", only: :dev},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:plug, "~> 1.6", only: :test},
     {:cowboy, "~> 1.0.0", only: :test}
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

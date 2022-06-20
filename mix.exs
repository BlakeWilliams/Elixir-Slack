defmodule Slack.Mixfile do
  use Mix.Project

  def project do
    [
      app: :slack,
      version: "0.23.6",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Slack",
      deps: deps(),
      docs: docs(),
      source_url: "https://github.com/BlakeWilliams/Elixir-Slack",
      description: "A Slack Real Time Messaging API client.",
      package: package()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:websocket_client, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:ex_doc, "~> 0.19", only: :dev},
      {:credo, "~> 1.6.4", only: [:dev, :test]},
      {:plug, "~> 1.6", only: :test},
      {:plug_cowboy, "~> 2.0", only: :test}
    ]
  end

  def docs do
    [
      {:main, Slack},
      {:assets, "guides/assets"},
      {:extra_section, "GUIDES"},
      {:extras, ["guides/token_generation_instructions.md"]}
    ]
  end

  defp package do
    %{
      maintainers: ["Blake Williams"],
      licenses: ["MIT"],
      links: %{
        Github: "https://github.com/BlakeWilliams/Elixir-Slack",
        Documentation: "http://hexdocs.pm/slack/"
      }
    }
  end
end

defmodule ExSlack.Mixfile do
  use Mix.Project

  def project do
    [app: :exslack,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [{:httpoison, "~> 0.5.0"},
     {:exjsx, "~> 3.1.0"},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client"}]
  end
end

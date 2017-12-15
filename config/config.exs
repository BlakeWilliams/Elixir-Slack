# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

if File.exists?("#{__DIR__}/#{Mix.env}.exs") do
  import_config "#{Mix.env}.exs"
end
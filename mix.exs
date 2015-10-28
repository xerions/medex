defmodule Medex.Mixfile do
  use Mix.Project

  def project do
    [app: :medex,
     version: "0.1.0",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :cowboy, :plug],
     mod: {Medex, []}]
  end

  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:consul, ">= 1.0.0", optional: true}]
  end
end

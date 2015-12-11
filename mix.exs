defmodule Medex.Mixfile do
  use Mix.Project

  def project do
    [app: :medex,
     version: "0.1.2",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: description,
     package: package]
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

  defp description do
    """
    Medical Examination - application for register health check callbacks and represent their state via HTTP.
    """
  end

  defp package do
    [maintainers: ["Yury Gargay"],
     links: %{"GitHub" => "https://github.com/xerions/medex"}]
  end
end

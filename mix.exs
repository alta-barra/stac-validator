defmodule StacValidator.MixProject do
  use Mix.Project

  def project do
    [
      app: :stac_validator,
      version: "0.1.0",
      elixir: "~> 1.17",
      organization: "alta-barra",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "StacValidator",
      source_url: "https://github.com/alta-barra/stac-validator",
      docs: [
        main: "StacValidator",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_json_schema, "~> 0.10.2"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 2.0"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:memoize, "~> 1.4", only: [:dev, :test]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description() do
    "A library for validating SpatioTemporal Asset Catalog (STAC) metadata"
  end

  defp package() do
    [
      name: "stac_validator",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alta-barra/stac-validator"}
    ]
  end
end

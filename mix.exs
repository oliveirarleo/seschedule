defmodule Seschedule.MixProject do
  use Mix.Project

  def project do
    [
      app: :seschedule,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Seschedule.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # TODO: remove in favor of bandit?
      {:req, "~> 0.4.0"},
      {:ex_gram, "~> 0.40.0"},
      {:tesla, "~> 1.2"},
      {:plug, "~> 1.15"},
      {:plug_cowboy, "~> 2.0"},
      {:hackney, "~> 1.12"},
      {:jason, ">= 1.0.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end

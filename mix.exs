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
      {:req, "~> 0.4.0"}, # TODO: remove in favor of tesla
      {:telegram, github: "visciang/telegram", tag: "1.1.0"},
      {:finch, "~> 0.16.0"},
      {:bandit, "~> 1.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end

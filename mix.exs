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
      mod: {Seschedule.Application, [env: Mix.env()]}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:telegex, "~> 1.3.2"},
      {:finch, "~> 0.16.0"},
      {:multipart, "~> 0.4.0"},
      {:plug, "~> 1.15"},
      {:remote_ip, "~> 1.1"},
      {:bandit, "~> 1.1"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end

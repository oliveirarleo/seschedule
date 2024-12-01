defmodule Seschedule.MixProject do
  use Mix.Project

  def project do
    [
      app: :seschedule,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:mix],
        flags: ["-Wunmatched_returns", :error_handling, :underspecs]
      ]
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
      {:telegex, "~> 1.8"},
      {:finch, "~> 0.19.0"},
      {:multipart, "~> 0.4.0"},
      {:plug, "~> 1.16"},
      {:remote_ip, "~> 1.2"},
      {:bandit, "~> 1.6"},
      {:protobuf, "~> 0.13"},
      {:ex_cldr, "~> 2.40"},
      {:ex_cldr_dates_times, "~> 2.20"},
      # Remove me at some point inf favor of finch
      {:req, "~> 0.5"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end

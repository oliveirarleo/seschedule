import Config

if config_env() == :prod do
  config :seschedule,
    token:
      System.get_env("TELEGRAM_TOKEN") ||
        raise("""
        environment variable TELEGRAM_TOKEN is missing.
        For example: 123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
        """),
    host:
      System.get_env("HOST") ||
        raise("""
        environment variable HOST is missing.
        For example: example.com
        """),
    port: System.get_env("PORT", "4000") |> String.to_integer(),
    max_concurrency: System.get_env("MAX_CONCURRENCY", "1000") |> String.to_integer()
end

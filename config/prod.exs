import Config

if config_env() == :prod do
  config :telegex,
    token:
      System.get_env("TELEGRAM_TOKEN") ||
        raise("""
        environment variable TELEGRAM_TOKEN is missing.
        For example: 123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
        """)

  config :seschedule,
    webhook_url:
      System.get_env("URL") ||
        raise("""
        environment variable HOST is missing.
        For example: https://seschedule.fly.dev/
        """)
end

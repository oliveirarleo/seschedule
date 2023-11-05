import Config

if config_env() == :prod do
  config :seschedule,
    token:
      System.get_env("TELEGRAM_TOKEN") ||
        raise("""
        environment variable TELEGRAM_TOKEN is missing.
        For example: 123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
        """),
    webhook_url: "https://seschedule.gigalixirapp.com/updates_hook"
end

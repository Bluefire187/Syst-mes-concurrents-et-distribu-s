import Config

config :dms, Dms.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "dms_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :dms, DmsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "S7m551i2stfnHb9crJTC3jinzkjd7DHlhlFE2RTTWDfkDpyGTyOKiIZC0JJYqiEE",
  server: false

config :dms, Dms.Mailer, adapter: Swoosh.Adapters.Test

config :swoosh, :api_client, false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  enable_expensive_runtime_checks: true

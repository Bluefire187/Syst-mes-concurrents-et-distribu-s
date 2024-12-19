import Config

# Configure the database
config :dms, Dms.Repo,
  username: "postgres",
  password: "1925",
  hostname: "localhost",
  database: "dms_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10




config :dms, DmsWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "PWeC9OmavM2q71vneQlZTra8uNGwdRX6vFWHxoxqehGDq+jS/kpf1+CNCF6ok0pD",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:dms, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:dms, ~w(--watch)]}
  ]


config :dms, DmsWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/dms_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]


config :dms, dev_routes: true
config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true
config :swoosh, :api_client, false

# General application configuration
import Config

config :dms,
  ecto_repos: [Dms.Repo],
  generators: [timestamp_type: :utc_datetime]


config :dms, DmsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DmsWeb.ErrorHTML, json: DmsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Dms.PubSub,
  live_view: [signing_salt: "dJOjZ6+G"]


config :dms, Dms.Mailer, adapter: Swoosh.Adapters.Local


config :esbuild,
  version: "0.17.11",
  dms: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]


config :tailwind,
  version: "3.4.3",
  dms: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]


config :dms, Dms.Vault,
  ciphers: [
    default: {Cloak.Ciphers.AES.GCM,
    tag: "AES.GCM.V1",
    key: Base.decode64!(System.get_env("CLOAK_KEY")),
    iv_length: 12}
  ]



config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


config :phoenix, :json_library, Jason


import_config "#{config_env()}.exs"

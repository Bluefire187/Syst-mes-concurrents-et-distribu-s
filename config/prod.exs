import Config

config :dms, DmsWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Dms.Finch

config :swoosh, local: false

config :logger, level: :info

defmodule Dms.Repo do
  use Ecto.Repo,
    otp_app: :dms,
    adapter: Ecto.Adapters.Postgres
end

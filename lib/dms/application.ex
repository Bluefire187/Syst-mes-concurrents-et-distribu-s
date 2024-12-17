defmodule Dms.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DmsWeb.Telemetry,
      Dms.Repo,
      Dms.Vault,
      {DNSCluster, query: Application.get_env(:dms, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Dms.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Dms.Finch},
      {Dms.MessageServer, []},
      DmsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dms.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DmsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

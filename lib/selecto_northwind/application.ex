defmodule SelectoNorthwind.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SelectoNorthwindWeb.Telemetry,
      SelectoNorthwind.Repo,
      {DNSCluster, query: Application.get_env(:selecto_northwind, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SelectoNorthwind.PubSub},
      # Start a worker by calling: SelectoNorthwind.Worker.start_link(arg)
      # {SelectoNorthwind.Worker, arg},
      # Start to serve requests, typically the last entry
      SelectoNorthwindWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SelectoNorthwind.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SelectoNorthwindWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

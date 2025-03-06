defmodule PubsubExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PubsubExampleWeb.Telemetry,
      PubsubExample.Repo,
      {DNSCluster, query: Application.get_env(:pubsub_example, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PubsubExample.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PubsubExample.Finch},
      # Start the Presence tracker
      PubsubExampleWeb.Presence,
      # Start a worker by calling: PubsubExample.Worker.start_link(arg)
      # {PubsubExample.Worker, arg},
      # Start to serve requests, typically the last entry
      PubsubExampleWeb.Endpoint,
      PubsubExample.Catalogos.Notifier
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PubsubExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PubsubExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

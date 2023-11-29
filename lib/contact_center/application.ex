defmodule ContactCenter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ContactCenterWeb.Telemetry,
      ContactCenter.Repo,
      {DNSCluster, query: Application.get_env(:contact_center, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ContactCenter.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ContactCenter.Finch},
      # Start a worker by calling: ContactCenter.Worker.start_link(arg)
      # {ContactCenter.Worker, arg},
      # Start to serve requests, typically the last entry
      ContactCenterWeb.Endpoint,
      {ContactCenter.Queue, friendly_name: "support"}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ContactCenter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ContactCenterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

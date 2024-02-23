defmodule ShortLinks.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShortLinksWeb.Telemetry,
      ShortLinks.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:short_links, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:short_links, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ShortLinks.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ShortLinks.Finch},
      # Start a worker by calling: ShortLinks.Worker.start_link(arg)
      # {ShortLinks.Worker, arg},
      # Start to serve requests, typically the last entry
      ShortLinksWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ShortLinks.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShortLinksWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end

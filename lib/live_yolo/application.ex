defmodule LiveYolo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveYoloWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveYolo.PubSub},
      # Start the Endpoint (http/https)
      LiveYoloWeb.Endpoint,
      # Start a worker by calling: LiveYolo.Worker.start_link(arg)
      {LiveYolo.Worker, [name: LiveYolo.Worker]},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveYolo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveYoloWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

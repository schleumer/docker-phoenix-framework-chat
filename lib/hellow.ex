defmodule Hellow do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Hellow.Endpoint, []),
      # Start websocket endpoint
      supervisor(Hellow.WebsocketEndpoint, []),

      worker(Task, [Hellow.TcpChannel, :init, []])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hellow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Hellow.Endpoint.config_change(changed, removed)
    Hellow.WebsocketEndpoint.config_change(changed, removed)
    :ok
  end
end

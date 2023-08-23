defmodule MiniMiner.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    numworkers = System.get_env("WORKERS") || 4
    interval = System.get_env("INTERVAL") || 1000

    children = [
      {MiniMiner.Miner, {numworkers, interval, name: MiniMiner.Miner}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MiniMiner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

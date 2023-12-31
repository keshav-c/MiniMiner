defmodule MiniMiner.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    args = %{
      numworkers: System.get_env("WORKERS") || 4,
      token: System.get_env("TOKEN")
    }

    children = [
      {Task.Supervisor, name: MiniMiner.HasherSupervisor},
      {MiniMiner.Miner, {args, name: MiniMiner.Miner}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MiniMiner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

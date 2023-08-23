defmodule MiniMiner.Miner do
  use GenServer

  require Logger

  # client API

  def start_link({numworkers, hash_interval, opts}) do
    GenServer.start_link(__MODULE__, {numworkers, hash_interval}, opts)
  end

  # callback
  @impl true
  def init({num_workers, hash_interval}) do
    {:ok, {num_workers, hash_interval}}
  end

  @impl true
  def handle_cast({:mine, prob_url, _solve_url}, {num_workers, hash_interval}) do
    %{"difficulty" => difficulty, "block" => %{"data" => data}} =
      MiniMiner.Util.get_data(prob_url)

    Logger.info("Difficulty: #{difficulty}")
    Logger.info("Data:\n#{inspect(data)}")
    {:noreply, {num_workers, hash_interval}}
  end

  # private functions
end

defmodule MiniMiner do
  require Logger

  def run do
    MiniMiner.Miner.fetch_problem()
    MiniMiner.Miner.mine()
  end
end

defmodule MiniMiner do
  require Logger

  @prob_url "https://hackattic.com/challenges/mini_miner/problem?access_token=8588d0e947f66656"
  @soln_url "https://hackattic.com/challenges/mini_miner/solve?access_token=8588d0e947f66656&playground=1"

  def run do
    GenServer.cast(MiniMiner.Miner, {:mine, @prob_url, @soln_url})
  end
end

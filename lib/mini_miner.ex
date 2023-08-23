defmodule MiniMiner do
  require Logger

  @prob_url "https://hackattic.com/challenges/mini_miner/problem?access_token=8588d0e947f66656"
  @soln_url "https://hackattic.com/challenges/mini_miner/solve?access_token=8588d0e947f66656&playground=1"

  def main() do
    data = get_data()
    Logger.info("Difficulty: #{Map.get(data, "difficulty")}")
    Logger.info("Data:\n#{inspect(get_in(data, ["block", "data"]))}")
    {_block, nonce, hash} = calc_nonce(data)
    Logger.info("Nonce: #{nonce}\tHash: #{hash}")
    send_solution(nonce)
  end

  def get_data() do
    {:ok, {{_version, 200, _msg}, _headers, body}} = :httpc.request(:get, {@prob_url, []}, [], [])
    Jason.decode!(body)
  end

  def send_solution(nonce) do
    body = Jason.encode!(%{"nonce" => nonce})

    :httpc.request(:post, {@soln_url, [], 'application/json', body}, [], [])
    |> IO.inspect()
    |> inspect()
    |> Logger.info()
  end

  @doc """
  Calculates the nonce for a given `block` and `difficulty`.

  ## Examples

      iex> MiniMiner.calc_nonce(%{"difficulty" => 8, "block" => %{"nonce" => nil, "data" => []}})
      {%{"nonce" => nil, "data" => []}, 45, "00D696DB487CAF06A2F2A8099479577C3785C37B3D8A77DC413CFB19EC2E0141"}
  """
  def calc_nonce(data) do
    %{"difficulty" => difficulty, "block" => block} = data
    loop_for_nonce(difficulty, block)
  end

  def loop_for_nonce(difficulty, block, nonce \\ 0) do
    hash = hash(block, nonce)

    case check(difficulty, hash) do
      :solved -> {block, nonce, Base.encode16(hash)}
      :not_solved -> loop_for_nonce(difficulty, block, nonce + 1)
    end
  end

  @doc """
  Calculates the sha256 hash of a `block` after inserting `nonce`.

  ## Examples

      iex> MiniMiner.hash(%{"nonce" => nil, "data" => []}, 45)
      <<0, 214, 150, 219, 72, 124, 175, 6, 162, 242, 168, 9, 148, 121, 87, 124, 55, 133, 195, 123, 61, 138, 119, 220, 65, 60, 251, 25, 236, 46, 1, 65>>

  """
  def hash(block, nonce) do
    data = block |> Map.put("nonce", nonce) |> Jason.encode!()
    :crypto.hash(:sha256, data)
  end

  @doc """
  Checks if the `hash` is a solution to the `difficulty`.

  ## Examples

      iex> MiniMiner.check(3, <<23>>)
      :solved

      iex> MiniMiner.check(8, <<0, 214, 150, 219, 72, 124, 175, 6, 162, 242, 168, 9, 148, 121, 87, 124, 55, 133, 195, 123, 61, 138, 119, 220, 65, 60, 251, 25, 236, 46, 1, 65>>)
      :solved

      iex> MiniMiner.check(9, <<0, 214, 150, 219>>)
      :not_solved
  """
  def check(difficulty, hash) do
    case hash do
      <<0::size(difficulty), _::bits>> -> :solved
      _ -> :not_solved
    end
  end
end

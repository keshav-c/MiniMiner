defmodule MiniMiner.Util do
  require Logger

  @spec get_data(String.t()) :: map()
  def get_data(prob_url) do
    {:ok, {{_version, 200, _msg}, _headers, body}} = :httpc.request(:get, {prob_url, []}, [], [])
    Jason.decode!(body)
  end

  def send_solution(solve_url, nonce) do
    body = Jason.encode!(%{"nonce" => nonce})

    :httpc.request(:post, {solve_url, [], 'application/json', body}, [], [])
    |> IO.inspect()
    |> inspect()
    |> Logger.info()

    :ok
  end
end

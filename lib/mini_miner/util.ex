defmodule MiniMiner.Util do
  require Logger

  @host "https://hackattic.com"

  @doc """
  Returns the URL to the problem given the access `token`.

  ## Examples

      iex> MiniMiner.Util.prob_url("bacd")
      "https://hackattic.com/challenges/mini_miner/problem?access_token=bacd"
  """
  def prob_url(token) do
    uri = URI.new!("#{@host}/challenges/mini_miner/problem")
    query = URI.encode_query(%{access_token: token})
    uri = URI.append_query(uri, query)
    URI.to_string(uri)
  end

  @doc """
  Returns the URL for posting the solution given the access `token`.
  For repeat tries, set `playground` to `true`.

  ## Examples

      iex> MiniMiner.Util.solution_url("bacd")
      "https://hackattic.com/challenges/mini_miner/solve?access_token=bacd"

      iex> MiniMiner.Util.solution_url("bacd", true)
      "https://hackattic.com/challenges/mini_miner/solve?access_token=bacd&playground=1"
  """
  def solution_url(token, playground) do
    uri = URI.new!("#{@host}/challenges/mini_miner/solve")

    query =
      if playground,
        do: URI.encode_query(%{access_token: token, playground: 1}),
        else: URI.encode_query(%{access_token: token})

    uri = URI.append_query(uri, query)
    URI.to_string(uri)
  end

  @spec get_data(String.t()) :: map()
  def get_data(token) do
    prob_url = prob_url(token)
    {:ok, {{_version, 200, _msg}, _headers, body}} = :httpc.request(:get, {prob_url, []}, [], [])
    Jason.decode!(body)
  end

  def send_solution(token, nonce, opts \\ []) do
    playground = Keyword.get(opts, :playground, false)
    solve_url = solution_url(token, playground)
    body = Jason.encode!(%{"nonce" => nonce})

    :httpc.request(:post, {solve_url, [], 'application/json', body}, [], [])
    |> inspect()
    |> Logger.info()

    :sent
  end
end

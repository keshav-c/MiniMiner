defmodule MiniMiner.Hasher do
  @doc """
  Calculates the nonce within range `min`..`max` for a given `block` and `difficulty`.

  ## Examples

      iex> MiniMiner.Hasher.find_nonce(8, %{"nonce" => nil, "data" => []}, 0, 99)
      {:found, 45, "00D696DB487CAF06A2F2A8099479577C3785C37B3D8A77DC413CFB19EC2E0141"}

      iex> MiniMiner.Hasher.find_nonce(8, %{"nonce" => nil, "data" => []}, 100, 199)
      :not_found
  """
  def find_nonce(difficulty, data, min, max) do
    Enum.each(min..max, fn nonce ->
      hash = hash(data, nonce)
      if solved?(difficulty, hash), do: throw({nonce, hash})
    end)

    :not_found
  catch
    {nonce, hash} -> {:found, nonce, Base.encode16(hash)}
  end

  @doc """
  Calculates the sha256 hash of a `block` after inserting `nonce`.

  ## Examples

      iex> MiniMiner.Hasher.hash(%{"nonce" => nil, "data" => []}, 45)
      <<0, 214, 150, 219, 72, 124, 175, 6, 162, 242, 168, 9, 148, 121, 87, 124, 55, 133, 195, 123, 61, 138, 119, 220, 65, 60, 251, 25, 236, 46, 1, 65>>

  """
  def hash(block, nonce) do
    data = block |> Map.put("nonce", nonce) |> Jason.encode!()
    :crypto.hash(:sha256, data)
  end

  @doc """
  Checks if the `hash` is a solution to the `difficulty`.

  ## Examples

      iex> MiniMiner.Hasher.solved?(3, <<23>>)
      true

      iex> MiniMiner.Hasher.solved?(8, <<0, 214, 150, 219, 72, 124, 175, 6, 162, 242, 168, 9, 148, 121, 87, 124, 55, 133, 195, 123, 61, 138, 119, 220, 65, 60, 251, 25, 236, 46, 1, 65>>)
      true

      iex> MiniMiner.Hasher.solved?(9, <<0, 214, 150, 219>>)
      false
  """
  def solved?(difficulty, hash) do
    case hash do
      <<0::size(difficulty), _::bits>> -> true
      _ -> false
    end
  end
end

# MiniMiner

Data

```
%{
  "data" => [],
  "nonce" => 45
}
```
Get hash (bitstring and string)

```
hash = map |> Jason.encode!() |> (&(:crypto.hash(:sha256, &1))).()
string_hash = hash |> Base.encode16 |> String.downcase
```
Pattern match
```
<<0::size(difficulty), _::binary>> = bitstring_hash
```
Synchronous request to get the problem
```
{:ok, {{version, status_code, msg}, headers, body}} =
  :httpc.request(:get, {'https://hackattic.com/challenges/mini_miner/problem?access_token=xxx', []}, [], [])
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mini_miner` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mini_miner, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/mini_miner>.


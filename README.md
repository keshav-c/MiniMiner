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
<<0::size(difficulty), _::bits>> = bitstring_hash
```
Synchronous request to get the problem
```
{:ok, {{version, status_code, msg}, headers, body}} =
  :httpc.request(:get, {'https://hackattic.com/challenges/mini_miner/problem?access_token=xxx', []}, [], [])
```

## Install
```sh
mix deps.get
```

## Run

```sh
TOKEN=xxx WORKERS=10 iex -S mix
```

## Test
```sh
mix test
```

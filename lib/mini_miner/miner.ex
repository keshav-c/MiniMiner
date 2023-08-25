defmodule MiniMiner.Miner do
  use GenServer

  require Logger

  # client API

  def start_link({args, opts}) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def fetch_problem() do
    GenServer.call(__MODULE__, {:fetch})
  end

  def mine() do
    GenServer.cast(__MODULE__, {:mine})
  end

  def report(result) do
    GenServer.cast(__MODULE__, result)
  end

  # callback
  @impl true
  def init(%{numworkers: _numworkers, token: _token} = state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:fetch}, _from, %{token: token} = state) do
    %{"difficulty" => difficulty, "block" => data} = MiniMiner.Util.get_data(token)

    Logger.info("Difficulty: #{difficulty}")
    Logger.info("Data:\n#{inspect(data)}")

    state =
      Map.merge(state, %{
        difficulty: difficulty,
        data: data,
        solved?: false
      })

    {:reply, :ok, state}
  end

  @impl true
  def handle_cast({:mine}, %{numworkers: numworkers, difficulty: difficulty, data: data} = state) do
    Enum.each(0..(numworkers - 1), fn nonce ->
      Task.Supervisor.start_child(
        MiniMiner.HasherSupervisor,
        MiniMiner.Hasher,
        :check_nonce,
        [difficulty, data, nonce],
        restart: :transient
      )
    end)

    {:noreply, Map.merge(state, %{next_nonce: numworkers})}
  end

  @impl true
  def handle_cast(
        {:not_found},
        %{difficulty: difficulty, data: data, solved?: solved?, next_nonce: nonce} = state
      ) do
    if solved? do
      {:noreply, state}
    else
      Task.Supervisor.start_child(
        MiniMiner.HasherSupervisor,
        MiniMiner.Hasher,
        :check_nonce,
        [difficulty, data, nonce],
        restart: :transient
      )

      {:noreply, %{state | next_nonce: nonce + 1}}
    end
  end

  @impl true
  def handle_cast({:found, nonce, hash}, state) do
    Logger.info("Found nonce: #{nonce} (Hash: #{hash})")

    Task.Supervisor.async(
      MiniMiner.HasherSupervisor,
      MiniMiner.Util,
      :send_solution,
      [state.token, nonce, [playground: true]],
      restart: :transient
    )
    |> Task.await()
    |> (&"Solution sent: #{inspect(&1)}").()
    |> Logger.info()

    {:noreply, %{state | solved?: true}}
  end
end

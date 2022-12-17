defmodule Day16 do

  require Logger

  alias __MODULE__.Cacher

  def solve1(suffix \\ "", depth) do
    data = Input.get_lines(16, suffix) |> Enum.map(&parse_line/1)
    adjacencies = Map.new(data, fn {key, _, adj} -> {key, adj} end)
    flows = Map.new(data, fn {key, flow, _} -> {key, flow} end)
    zero_flow_nodes = flows |> Enum.filter(&(elem(&1,1) == 0 and elem(&1, 0) != "AA")) |> Enum.map(&elem(&1, 0))
    adjacencies = Enum.reduce(zero_flow_nodes, adjacencies, &remove_valve/2)

    cacher = Cacher.start_link() |> elem(1)
    walk({"AA", depth, MapSet.new()}, {adjacencies, flows, cacher})
  end

  def remove_valve(valve, adjacencies) do
    Logger.warn("Removing #{inspect(valve)} from #{inspect(adjacencies)}")
    Enum.reduce(adjacencies[valve], adjacencies, &add_reachables(&2, &1, valve))
      |> Map.delete(valve)
  end

  def add_reachables(adjacencies, {src, dist}, dest) do
    updated_adjacencies = Enum.reduce(adjacencies[dest], adjacencies[src], &update_adjacency(&1, &2, dist, src))
    Map.put(adjacencies, src, Map.delete(updated_adjacencies, dest))
  end

  def update_adjacency({src, _extra_dist}, existing_adjacencies, _base_dist, src) do
    existing_adjacencies
  end

  def update_adjacency({new_dest, extra_dist}, existing_adjacencies, base_dist, _src) do
    case Map.fetch(existing_adjacencies, new_dest) do
      :error -> Map.put(existing_adjacencies, new_dest, extra_dist + base_dist)
      {:ok, existing_dist} ->
        Map.put(existing_adjacencies, new_dest, min(extra_dist + base_dist, existing_dist))
    end
  end

  def parse_line(line) do
    parts = String.split(line, [", ", " ",";","="])
    {Enum.at(parts, 1), String.to_integer(Enum.at(parts, 5)), Enum.slice(parts, 11, 100) |> Map.new(&{&1, 1})}
  end

  def walk({pos, time_remain, enabled} = state, {_adjacencies, _flows, cacher} = ctx) do
    case GenServer.call(cacher, {:fetch, state}) do
      {:ok, score} ->
        score

      :error ->
        remain = compute(state, ctx)
        GenServer.cast(cacher, {:cache, state, remain})
        remain
    end
  end

  def compute({pos, 0, enabled} = state, ctx) do
    0
  end

  def compute({pos, time_remain, enabled} = state, {adjacencies, flows, cacher} = ctx) do
    possibilities = [enable(state, ctx) | Enum.map(adjacencies[pos], &visit(&1, state, ctx))]
    Enum.max(possibilities)
  end

  def enable({pos, time_remain, enabled} = state, {_adjacencies, flows, cacher} = ctx) do
    if MapSet.member?(enabled, pos) and flows[pos] > 0 do
      walk({pos, time_remain - 1, enabled}, ctx)
    else
      walk({pos, time_remain - 1, MapSet.put(enabled, pos)}, ctx) + time_remain * flows[pos]
    end
  end

  def visit({dest, cost}, {pos, time_remain, enabled} = state, ctx) when cost >= time_remain do
    0
  end
  def visit({dest, cost}, {pos, time_remain, enabled} = state, ctx) do
    walk({dest, time_remain - cost, enabled}, ctx)
  end

  defmodule Cacher do
    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, :ok)
    end

    def init(_) do
      {:ok, %{}}
    end

    def handle_cast({:cache, key, value}, state) do
      # Logger.warn("Caching #{value} for #{inspect(key)}")
      {:noreply, Map.put(state, key, value)}
    end

    def handle_call({:fetch, key}, _from, state) do
      {:reply, Map.fetch(state, key), state}
    end
  end

end

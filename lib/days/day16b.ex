defmodule Day16B do

  require Logger

  alias __MODULE__.Cacher

  def solve1(suffix \\ "", depth) do
    data = Input.get_lines(16, suffix) |> Enum.map(&parse_line/1)
    adjacencies = Map.new(data, fn {key, _, adj} -> {key, adj} end)
    flows = Map.new(data, fn {key, flow, _} -> {key, flow} end)
    zero_flow_nodes = flows |> Enum.filter(&(elem(&1,1) == 0 and elem(&1, 0) != "AA")) |> Enum.map(&elem(&1, 0))
    adjacencies = floyd_warshall(adjacencies) |> clean_up(zero_flow_nodes)
    Logger.warn("Final adjacencies are #{inspect(adjacencies)}")

    cacher = :ets.new(:items, [:set])
    {walk({{:at, "AA"}, {:at, "AA"}, depth, MapSet.new()}, {adjacencies, flows, cacher}), cacher}
  end

  def floyd_warshall(adjacencies) do
    Enum.reduce(Map.keys(adjacencies), adjacencies, &floyd_warshall_step/2)
  end

  def floyd_warshall_step(pivot, adjacencies) do
    Map.new(adjacencies, &floyd_warshall_relax(&1, adjacencies[pivot], pivot))
  end

  def floyd_warshall_relax({src, dests}, adjacencies_from_pivot, pivot) do
    if Map.has_key?(dests, pivot) do
      dist_to_pivot = dests[pivot]
      {src, Enum.reduce(adjacencies_from_pivot, dests, fn {dest, dist_from_pivot}, dests -> Map.update(dests, dest, dist_to_pivot + dist_from_pivot, &min(&1, dist_to_pivot + dist_from_pivot)) end)}
    else
      {src, dests}
    end
  end

  def clean_up(adjacencies, zero_flow_nodes) do
    adjacencies |> Map.drop(zero_flow_nodes) |> Map.new(fn {k, v} -> {k, Map.drop(v, zero_flow_nodes)} end)
  end

  def parse_line(line) do
    parts = String.split(line, [", ", " ",";","="])
    {Enum.at(parts, 1), String.to_integer(Enum.at(parts, 5)), Enum.slice(parts, 11, 100) |> Map.new(&{&1, 1})}
  end

  def walk({pos1, pos2, time_remain, enabled}, ctx) when pos2 > pos1 do
    walk({pos2, pos1, time_remain, enabled}, ctx)
  end

  def walk({{:move, :nowhere, _}, {:move, :nowhere, _}, _time_remain, _enabled}, _ctx)do
    0
  end

  def walk(state, {_adjacencies, _flows, cacher} = ctx) do
    case :ets.lookup(cacher, state) do
      [{_state, score}] ->
        score

      [] ->
        {score, newstate} = compute(state, ctx)
        #Logger.warn("Caching #{score} from #{inspect(state)} to #{inspect(newstate)}")
        :ets.insert(cacher, {state, score})
        score
    end
  end

  def compute({_pos1, _pos2, 0, _enabled}, ctx) do
    {0, nil}
  end

  def compute({pos1, pos2, time_remain, enabled} = state, {adjacencies, flows, cacher} = ctx) do
    possibilities1 = make_possibilities(pos1, enabled, adjacencies)
    possibilities2 = make_possibilities(pos2, enabled, adjacencies)

    possibilities = for x <- possibilities1, y <- possibilities2 do
      if elem(x, 1) != elem(y, 1) or elem(x, 1) == :nowhere do
        {inc, next_state} = next(state, ctx, x, y)
        {walk(next_state, ctx) + inc, next_state}
      else
        {0, state}
      end
    end

    Enum.max(possibilities)
  end

  def make_possibilities({:at, pos1}, enabled, adjacencies) do
    [{:move, :nowhere, 100000} | Enum.map(adjacencies[pos1], fn {dest, dist} -> {:move, dest, dist} end) |> Enum.reject(&MapSet.member?(enabled, elem(&1,1)))]
  end

  def make_possibilities({:move, :nowhere, dist}, _, _) do
    [{:move, :nowhere, dist}]
  end

  def make_possibilities({:move, dest, dist}, _, _) do
    [{:move, dest, dist - 1}]
  end

  def next({pos1, pos2, time_remain, enabled} = state, {_adjacencies, flows, _cacher} = ctx, {:move, dest1, ttl1}, {:move, dest2, ttl2}) do
    next_p1 = if ttl1 == 0 do
      {:at, dest1}
    else
      {:move, dest1, ttl1 }
    end

    next_p2 = if ttl2 == 0 do
      {:at, dest2}
    else
      {:move, dest2, ttl2}
    end

    score1 = if elem(pos1, 0) == :at do
      flows[elem(pos1, 1)]
    else
      0
    end

    score2 = if elem(pos2, 0) == :at do
      flows[elem(pos2, 1)]
    else
      0
    end

    {(time_remain - 1) * (score1 + score2), {next_p1, next_p2, time_remain - 1, enabled |> record(dest1) |> record(dest2)}}
  end

  def record(enabled, dest) do
    MapSet.put(enabled, dest)
  end



  defmodule Cacher do
    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, :ok)
    end

    def init(_) do
      {:ok, :ets.new(:items, [:set])}
    end

    def handle_cast({:cache, key, value}, state) do
      if rem(Enum.count(state),1000000) == 0 do
        Logger.warn("Cached #{Enum.count(state)} things")
      end
      {:noreply, Map.put(state, key, value)}
    end

    def handle_call({:fetch, key}, _from, state) do
      {:reply, Map.fetch(state, key), state}
    end
  end

end

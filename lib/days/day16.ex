defmodule Day16 do
  require Logger

  ################ Input handling / graph construction ##############
  def get_case(suffix) do
    data = Input.get_lines(16, suffix) |> Enum.map(&parse_line/1)
    adjacencies = Map.new(data, fn {key, _, adj} -> {key, adj} end)
    flows = Map.new(data, fn {key, flow, _} -> {key, flow} end)

    zero_flow_nodes =
      flows |> Enum.filter(&(elem(&1, 1) == 0 and elem(&1, 0) != "AA")) |> Enum.map(&elem(&1, 0))

    adjacencies = floyd_warshall(adjacencies) |> clean_up(zero_flow_nodes)
    flows = Enum.filter(flows, fn {_, v} -> v != 0 end) |> Map.new()

    {adjacencies, flows}
  end

  def parse_line(line) do
    parts = String.split(line, [", ", " ", ";", "="])

    {Enum.at(parts, 1), String.to_integer(Enum.at(parts, 5)),
     Enum.slice(parts, 11, 100) |> Map.new(&{&1, 1})}
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

      {src,
       Enum.reduce(adjacencies_from_pivot, dests, fn {dest, dist_from_pivot}, dests ->
         Map.update(
           dests,
           dest,
           dist_to_pivot + dist_from_pivot,
           &min(&1, dist_to_pivot + dist_from_pivot)
         )
       end)}
    else
      {src, dests}
    end
  end

  def clean_up(adjacencies, zero_flow_nodes) do
    adjacencies
    |> Map.drop(zero_flow_nodes)
    |> Map.new(fn {k, v} -> {k, Map.drop(v, zero_flow_nodes)} end)
  end

  ################################### Top-level solution logic ##############

  def solve1(suffix \\ "", depth) do
    {adjacencies, flows} = get_case(suffix)

    cacher = :ets.new(:items, [:set])
    solve_all_cases([flows], {adjacencies, cacher}, depth)
  end

  def solve2(suffix \\ "", depth) do
    {adjacencies, flows} = get_case(suffix)

    cacher = :ets.new(:items, [:public, :set])

    subsets = powerset(Enum.to_list(flows), []) |> Enum.map(&Map.new/1)

    data =
      solve_all_cases(subsets, {adjacencies, cacher}, depth)
      |> Enum.map(fn {:ok, {map, score}} -> {MapSet.new(Map.keys(map)), score} end)
      |> Enum.sort_by(fn {_k, v} -> v end, :desc)

    :ets.delete(cacher)

    find_best_score(data, 0)
  end

  def find_best_score([], best) do
    best
  end

  def find_best_score([{nodes, score} | rest], best) do
    if best >= score * 2 do
      best
    else
      candidate = Enum.find(rest, &MapSet.disjoint?(nodes, elem(&1, 0)))
      new_score = elem(candidate, 1) + score

      if new_score > best do
        Logger.warn("Found #{new_score} from #{inspect(nodes)} + #{inspect(candidate)}")
        find_best_score(rest, elem(candidate, 1) + score)
      else
        find_best_score(rest, best)
      end
    end
  end

  def solve_all_cases(cases, ctx, depth) do
    Task.async_stream(
      Enum.sort_by(cases, &Enum.count(&1)) |> Enum.with_index(),
      fn {c, idx} -> {c, solve(idx, {"AA", depth, c}, ctx)} end,
      timeout: :infinity
    )
    |> Enum.to_list()
  end

  ########################## Find best path through the maze given a usable set ##########

  def solve(i, state, ctx) do
    if rem(i, 100) == 0 do
      Logger.warn("Starting case #{i}")
    end

    walk(state, ctx)
  end

  def walk(state, {adjacencies, cacher}) do
    case get_cached(cacher, state) do
      {:ok, value} ->
        value

      :error ->
        ret = compute(state, {adjacencies, cacher})
        cache(cacher, state, ret)
        ret
    end
  end

  def compute({_, 0, _}, _) do
    0
  end

  def compute({_, _, visitable}, _) when map_size(visitable) == 0 do
    0
  end

  def compute({current, depth, visitable}, {adjacencies, _} = ctx) do
    possibilities =
      Enum.map(visitable, fn {dest, flow} ->
        {dest, local_walk(depth, adjacencies[current][dest], flow)}
      end)

    scores =
      Enum.map(possibilities, fn {dest, {new_depth, local_score}} ->
        local_score + walk({dest, new_depth, Map.delete(visitable, dest)}, ctx)
      end)

    Enum.max(scores)
  end

  def local_walk(curr_depth, distance, flow) do
    if distance >= curr_depth do
      {0, 0}
    else
      new_depth = curr_depth - (distance + 1)
      {new_depth, new_depth * flow}
    end
  end

  ########################## Random utils ####################

  def powerset([], sofar) do
    [sofar]
  end

  def powerset([h | t], sofar) do
    powerset(t, sofar) ++ powerset(t, [h | sofar])
  end

  def get_cached(cacher, key) do
    case :ets.lookup(cacher, key) do
      [] -> :error
      [{^key, score}] -> {:ok, score}
    end
  end

  def cache(cacher, key, value) do
    :ets.insert(cacher, {key, value})
  end
end

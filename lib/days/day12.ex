defmodule Day12 do
  require Logger

  def solve1(suffix \\ "") do
    results =
      Input.get_lines(12, suffix)
      |> to_grid(fn c -> if c == ?S, do: 0, else: 9_999_999 end)
      |> dijkstra()

    results |> Map.values() |> Map.new() |> Map.get(?E)
  end

  def solve2(suffix \\ "") do
    results =
      Input.get_lines(12, suffix)
      |> to_grid(fn c -> if c == ?a, do: 0, else: 9_999_999 end)
      |> dijkstra()

    results |> Map.values() |> Map.new() |> Map.get(?E)
  end

  def to_grid(data, init) do
    data
    |> Enum.with_index()
    |> Enum.map(fn {row, row_idx} ->
      row
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.map(fn {c, col_idx} -> {{row_idx, col_idx}, {c, init.(c)}} end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  def set_distance(grid, point, distance) do
    {height, old_dist} = grid[point]
    # Logger.warn("Setting distance #{inspect({grid, point, distance})}")
    Map.put(grid, point, {height, min(distance, old_dist)})
  end

  def dijkstra(grid) do
    do_dijkstra(grid, Map.keys(grid))
  end

  def do_dijkstra(grid, []), do: grid

  def do_dijkstra(grid, unvisited) do
    [src | remain_unvisited] = Enum.sort_by(unvisited, &(Map.get(grid, &1) |> elem(1)))
    {src_char, src_cost} = Map.get(grid, src)

    # Logger.warn("Doing dijkstra #{inspect(grid)} selected #{inspect(src)} #{inspect(src_char)} #{inspect(src_cost)}")

    updated_grid =
      src
      |> neighbors4()
      |> Enum.filter(&reachable(src_char, Map.get(grid, &1, {nil, nil}) |> elem(0)))
      |> Enum.reduce(grid, fn point, grid -> set_distance(grid, point, src_cost + 1) end)

    do_dijkstra(updated_grid, remain_unvisited)
  end

  def neighbors4({x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
  end

  def reachable(x, ?E), do: reachable(x, ?z)
  def reachable(?S, ?a), do: true
  def reachable(x, y) when y <= x, do: true
  def reachable(x, y) when x + 1 == y, do: true
  def reachable(_, _), do: false
end

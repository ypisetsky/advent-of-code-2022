defmodule Day23 do
  def solve1(suffix \\ "") do
    data = Input.get_lines(23, suffix) |> parse_map()

    {final_points, _} = Enum.reduce_while(1..10, data, fn i, acc -> run_generation(i, acc) end)

    minx = Enum.map(final_points, &elem(&1, 0)) |> Enum.sort() |> List.first()
    maxx = Enum.map(final_points, &elem(&1, 0)) |> Enum.sort() |> List.last()

    miny = Enum.map(final_points, &elem(&1, 1)) |> Enum.sort() |> List.first()
    maxy = Enum.map(final_points, &elem(&1, 1)) |> Enum.sort() |> List.last()

    (maxx - minx + 1) * (maxy - miny + 1) - Enum.count(final_points)
  end

  def solve2(suffix \\ "") do
    data = Input.get_lines(23, suffix) |> parse_map()

    Enum.reduce_while(1..1_000_000_000, data, fn i, acc -> run_generation(i, acc) end)
  end

  def parse_map(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), &parse_line/2)
  end

  def parse_line({line, row}, points) do
    line
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.filter(&(elem(&1, 0) == ?#))
    |> Enum.reduce(points, fn {_, j}, acc -> MapSet.put(acc, {row, j}) end)
  end

  def neighbors8({x, y}) do
    [
      {x - 1, y - 1},
      {x - 1, y},
      {x - 1, y + 1},
      {x, y - 1},
      {x, y + 1},
      {x + 1, y - 1},
      {x + 1, y},
      {x + 1, y + 1}
    ]
  end

  @rules [
    {[0, 1, 2], {-1, 0}},
    {[5, 6, 7], {1, 0}},
    {[0, 3, 5], {0, -1}},
    {[2, 4, 7], {0, 1}}
  ]

  def move([false, false, false, false, false, false, false, false], _rules) do
    {0, 0}
  end

  def move(state, []) do
    {0, 0}
  end

  def move(state, [{rule, effect} | rules]) do
    if Enum.any?(rule, &Enum.at(state, &1)) do
      move(state, rules)
    else
      effect
    end
  end

  def run_generation(i, %MapSet{} = elves) do
    run_generation(i, {elves, @rules})
  end

  def run_generation(i, {elves, move_rules}) do
    elf_to_dest = Enum.map(elves, &{&1, move_elf(&1, elves, move_rules)})
    dest_to_source = Enum.reduce(elf_to_dest, %{}, &try_move_elf/2)
    [first | others] = move_rules
    new_elves = Map.keys(dest_to_source) |> MapSet.new()

    if new_elves == elves do
      {:halt, i}
    else
      {:cont, {new_elves, others ++ [first]}}
    end
  end

  def move_elf({x, y} = elf, elves, rules) do
    grid = Enum.map(neighbors8(elf), &MapSet.member?(elves, &1))
    {dx, dy} = move(grid, rules)
    {x + dx, y + dy}
  end

  def try_move_elf({elf, dest}, dest_to_source) do
    if Map.has_key?(dest_to_source, dest) do
      old_source = dest_to_source[dest]

      dest_to_source
      |> Map.delete(dest)
      |> Map.put(old_source, old_source)
      |> Map.put(elf, elf)
    else
      Map.put(dest_to_source, dest, elf)
    end
  end
end

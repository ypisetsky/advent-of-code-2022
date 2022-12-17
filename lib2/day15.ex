defmodule Day15 do
  require Logger

  def parse_line(line) do
    [sx, sy, bx, by] =
      String.split(line, ["=", ",", ":"])
      |> Enum.filter(&String.match?(&1, ~r/^[-0-9]+$/))
      |> Enum.map(&String.to_integer/1)

    distance = abs(bx - sx) + abs(by - sy)
    {{{sx, sy}, distance}, {bx, by}}
  end

  def solve1(suffix \\ "") do
    data = Input.get_lines(15, suffix) |> Enum.map(&parse_line/1)
    exclusions = Enum.map(data, &elem(&1, 0))
    beacons = MapSet.new(Enum.map(data, &elem(&1, 1)))

    target_y = if suffix == "", do: 2_000_000, else: 10

    rejected =
      Enum.reduce(exclusions, MapSet.new(), fn {start, distance}, rejected ->
        add_rejects(start, distance, rejected, target_y)
      end)

    MapSet.difference(rejected, beacons) |> Enum.count()
  end

  def add_rejects({sx, sy}, distance, rejected, target_y) do
    dy = abs(target_y - sy)
    offset = distance - dy
    Logger.warn("#{inspect({sx, sy, distance, offset})}")

    if offset < 0 do
      rejected
    else
      Enum.reduce((sx - offset)..(sx + offset), rejected, &MapSet.put(&2, {&1, target_y}))
    end
  end

  def solve2(suffix \\ "") do
    data = Input.get_lines(15, suffix) |> Enum.map(&parse_line/1)
    exclusions = Enum.map(data, &elem(&1, 0))

    max_y = if suffix == "", do: 4_000_000, else: 20

    Enum.map(0..max_y, &check_it(&1, exclusions, max_y)) |> Enum.reject(&is_nil/1)
  end

  def check_it(y, exclusions, max_y) do
    ret = Enum.reduce(exclusions, [{0, max_y}], &remove_slice(&2, to_slice(&1, y)))

    if ret != [] do
      [{x, x}] = ret
      4_000_000 * x + y
    end
  end

  def remove_slice(ranges, nil) do
    ranges
  end

  def remove_slice([], _) do
    []
  end

  def remove_slice(ranges, {low, high}) do
    Enum.map(ranges, fn {range_low, range_high} = range ->
      cond do
        low > range_high or high < range_low ->
          [range]

        high >= range_high and low <= range_low ->
          []

        high >= range_high ->
          [{range_low, low - 1}]

        low <= range_low ->
          [{high + 1, range_high}]

        true ->
          [{range_low, low - 1}, {high + 1, range_high}]
      end
    end)
    |> Enum.concat()
  end

  def to_slice({{sx, sy}, distance}, y) do
    dy = abs(y - sy)
    offset = distance - dy

    if offset < 0 do
      nil
    else
      {sx - offset, sx + offset}
    end
  end
end

defmodule Day20 do
  require Logger

  def solve1(suffix \\ "") do
    solve(suffix, 1, 1)
  end

  def solve2(suffix \\ "") do
    solve(suffix, 10, 811_589_153)
  end

  def solve(suffix \\ "", loops, mult) do
    data = Input.get_lines(20, suffix) |> Enum.map(&String.to_integer/1) |> Enum.with_index()
    datamap = data |> Map.new(fn {k, v} -> {{k, v}, v} end)

    datamap =
      Enum.reduce(1..loops, datamap, fn _, datamap ->
        Enum.reduce(data, datamap, &move_element(&1, &2, mult))
      end)

    zero_pos = datamap |> Enum.filter(fn {{x, _}, _} -> x == 0 end) |> hd |> elem(1)

    pos_to_value = datamap |> Map.new(fn {{x, _}, y} -> {y, x} end)

    len = Enum.count(data)

    mult *
      (pos_to_value[clamp(zero_pos + 1000, len)] + pos_to_value[clamp(zero_pos + 2000, len)] +
         pos_to_value[clamp(zero_pos + 3000, len)])
  end

  def move_element({element, _} = e, data, mult) do
    old_pos = data[e]
    new_pos = clamp(old_pos + element * mult, map_size(data) - 1)
    inc = if new_pos >= old_pos, do: -1, else: 1

    ret =
      Map.new(data, fn {el, pos} ->
        cond do
          el == e ->
            {e, new_pos}

          pos in old_pos..new_pos ->
            {el, pos + inc}

          true ->
            {el, pos}
        end
      end)

    ret
  end

  def clamp(val, sz) do
    rem(val + sz * 100_000_000_000, sz)
  end
end

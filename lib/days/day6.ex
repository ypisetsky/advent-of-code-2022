defmodule Day6 do
  require Logger
  def solve1(suffix \\ "") do
    data = Input.get_lines(6, suffix) |> hd |> String.to_charlist

    [a,b,c | rest] = data

    pos(rest, a, b, c, 4)
  end

  def pos([x | rest], a, b, c, i) when x == a when x == b when x == c when a == b when a == c when b == c do
    pos(rest, b, c, x, i + 1)
  end

  def pos(arr,a,b,c,i) do
    Logger.warn("Good #{inspect(arr)} #{a} #{b} #{c} #{i}")
    i
  end


  def solve2(suffix \\ "") do
    data = Input.get_lines(6, suffix) |> hd |> String.to_charlist

    {prefix, rest} = Enum.split(data, 13)

    freqs = prefix

    pos2(rest, Enum.reverse(prefix), 13) + 1
  end

  def pos2([x | rest], sofar, i) do
    cond do
      Enum.count(sofar) != Enum.count(Enum.uniq(sofar)) -> pos2(rest, Enum.take([x | sofar], 13), i + 1)

      x in sofar -> pos2(rest, Enum.take([x | sofar], 13), i + 1)

      true ->
        Logger.warn("Rest is #{rest} sofar is #{sofar}")
        i
    end
  end
end

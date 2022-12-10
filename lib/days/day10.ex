defmodule Day10 do

  require Logger

  def solve1(suffix \\ "") do
    lines = Input.get_lines(10, suffix)
    state = {1, [1,1]}
    {_, history} = Enum.reduce(lines, state, &process_instruction/2)
    history_map = history
      |> Enum.reverse()
      |> Enum.with_index
      |> Enum.map(fn {a,b} -> {b,a} end)
      |> Map.new()

    [20, 60, 100, 140, 180, 220]
      |> Enum.map(&score(history_map, &1))
      |> Enum.sum()
  end

  def solve2(suffix \\ "") do
    lines = Input.get_lines(10, suffix)
    state = {1, [1]}
    {_, history} = Enum.reduce(lines, state, &process_instruction/2)

    history
      |> Enum.reverse()
      |> Enum.with_index
      |> Enum.map(&to_char/1)
      |> Enum.chunk_every(40)

  end

  def to_char({x, time}) do
    xp1 = x + 1
    xm1 = x - 1
    case rem(time, 40) do
      ^x -> ?*
      ^xp1 -> ?*
      ^xm1 -> ?*
      _ -> ?\s
    end
  end

  def score(history, day) do
    Logger.warn("Score on day #{day} is #{history[day]}")
    day * history[day]
  end

  def process_instruction("noop", {value, history}) do
    {value, [value | history]}
  end

  def process_instruction(add, {value, history}) do
    ["addx", val] = String.split(add, " ")
    intval = String.to_integer(val)
    {value + intval, [value + intval, value | history]}
  end
end

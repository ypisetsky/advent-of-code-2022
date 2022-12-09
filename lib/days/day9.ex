defmodule Day9 do

  require Logger

  def solve1(suffix \\ "") do
    solve(suffix, 2)
  end

  def solve2(suffix \\ "") do
    solve(suffix, 10)
  end

  def solve(suffix, n) do
    lines = Input.get_lines(9, suffix)

    Enum.reduce(lines, {%{}, startstate(n)}, &walkline/2) |> elem(0) |> Enum.count()
  end

  def startstate(i) do
    1..i |> Enum.map(fn _ -> {0,0} end)
  end

  def walkline(line, state) do
    [dir, countstr] = String.split(line, " ")
    count = String.to_integer(countstr)
    Enum.reduce(1..count, state, fn _, state -> walkstep(dir, state) end)
  end

  def walkstep(dir, {visited, [head | tails]}) do
    new_head = headstep(head, dir)
    new_snakes = Enum.reduce(tails, [new_head], &tail_reduce/2)
    new_visited = Map.put(visited, hd(new_snakes), 1)
    {new_visited, Enum.reverse(new_snakes)}
  end

  def headstep({hi, hj}, "R") do
    {hi + 1, hj}
  end

  def headstep({hi, hj}, "L") do
    {hi - 1, hj}
  end

  def headstep({hi, hj}, "U") do
    {hi, hj - 1}
  end

  def headstep({hi, hj}, "D") do
    {hi, hj + 1}
  end

  def movecloser(hx, hx), do: hx
  def movecloser(hx, tx) when tx > hx, do: tx - 1
  def movecloser(hx, tx) when tx < hx, do: tx + 1

  def tail_reduce(tail, [head | _] = sofar) do
    new_tail = tailstep(head, tail)
    [new_tail | sofar]
  end

  def tailstep({hi, hj} = head, {ti, tj} = tail) do
    new_tail = {movecloser(hi, ti), movecloser(hj, tj)}
    if new_tail == head do
      tail
    else
      new_tail
    end
  end


end

defmodule Day13 do
  def solve1(suffix \\ "") do
    Input.get_lines(13, suffix)
    |> Enum.chunk_every(3)
    |> Enum.map(&parse_case/1)
    |> Enum.map(&cmp/1)
    |> Enum.with_index()
    |> Enum.filter(&(elem(&1, 0) >= 0))
    |> Enum.map(&(elem(&1, 1) + 1))
    |> Enum.sum()
  end

  def solve2(suffix \\ "") do
    data =
      Input.get_lines(13, suffix)
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(&(Code.eval_string(&1) |> elem(0)))
      |> Enum.concat([[[2]], [[6]]])
      |> Enum.sort(&(cmp(&1, &2) > 0))
      |> Enum.with_index()
      |> Map.new()

    (1 + data[[[2]]]) * (1 + data[[[6]]])
  end

  def parse_case(lines) do
    [{first, []}, {second, []} | _] = Enum.map(lines, &Code.eval_string/1)
    {first, second}
  end

  def cmp({x, y}) do
    cmp(x, y)
  end

  def cmp([], []) do
    0
  end

  def cmp([], [_ | _]) do
    1
  end

  def cmp([_ | _], []) do
    -1
  end

  def cmp([xh | xt], [yh | yt]) do
    case cmp(xh, yh) do
      0 -> cmp(xt, yt)
      other -> other
    end
  end

  def cmp(x, y) when is_integer(x) and is_integer(y) do
    y - x
  end

  def cmp(x, y) when is_integer(x) and is_list(y) do
    cmp([x], y)
  end

  def cmp(x, y) when is_integer(y) and is_list(x) do
    cmp(x, [y])
  end
end

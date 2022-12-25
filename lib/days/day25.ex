defmodule Day25 do
  require Logger
  def solve(suffix \\ "") do
    data = Input.get_lines(25, "")
    data
      |> Enum.map(&to_decimal(String.to_charlist(&1), 0))
      |> Enum.sum()
      |> to_snafu([])


  end

  def to_decimal([], sofar) do
    sofar
  end

  def to_decimal([c | rest], sofar) do
    to_decimal(rest, sofar * 5 + conv(c))
  end

  def conv(?2), do: 2
  def conv(?1), do: 1
  def conv(?0), do: 0
  def conv(?-), do: -1
  def conv(?=), do: -2

  def to_snafu(0, sofar) do
    sofar
  end

  def to_snafu(num, sofar) do
    ones = rem(num, 5)
    rest = div(num, 5)
    case ones do
      0 -> to_snafu(rest, [?0 | sofar])
      1 -> to_snafu(rest, [?1 | sofar])
      2 -> to_snafu(rest, [?2 | sofar])
      3 -> to_snafu(rest + 1, [?= | sofar])
      4 -> to_snafu(rest + 1, [?- | sofar])
    end
  end
end

defmodule Day5 do
  require Logger

  def solve1(suffix \\ "") do
    solve(suffix, &move/4)
  end

  def solve2(suffix \\ "") do
    solve(suffix, &move2/4)
  end

  def solve(suffix, cb) do
    {state, data_lines} = Input.get_lines(5, suffix) |> parse_input()

    state = Enum.reduce(data_lines, state, &process_data_line(&1, &2, cb))

    state |> Map.values() |> Enum.map(&hd/1)
  end

  def move(state, src, dest, 0) do
    state
  end

  def move(state, src, dest, n) do
    [h | rest] = state[src]
    state = %{state | src => rest, dest => [h | state[dest]]}
    move(state, src, dest, n - 1)
  end

  def move2(state, src, dest, n) do
    {h, rest} = Enum.split(state[src], n)
    state = state = %{state | src => rest, dest => h ++ state[dest]}
  end

  def parse_input(data) do
    {state_lines, data_lines} = Enum.split_while(data, &(&1 != ""))

    state_lines = Enum.reverse(state_lines) |> Enum.drop(1)


    state = Enum.reduce(state_lines, init_state(), &parse_state_line/2)

    {state, Enum.drop(data_lines, 1)}
  end

  def process_data_line(line, state, cb) do
    [_, count, _, src, _, dest] = String.split(line, " ")
    cb.(state, src, dest, String.to_integer(count))
  end


  def parse_state_line(line, state) do
    line
    |> String.to_charlist()
    |> Enum.drop(1)
    |> Enum.take_every(4)
    |> Enum.with_index()
    |> Enum.reduce(state, &add_value/2)
  end

  def add_value({?\s, _index}, state) do
    state
  end

  def add_value({value, index}, state) do
    Map.update!(state, from_index(index), &[value | &1])
  end

  def init_state() do
    Map.new(Enum.map(0..8, &{from_index(&1), [?-]}))
  end

  def from_index(i) do
    "#{i + 1}"
  end
end

defmodule Day11 do
  require Logger

  def modulus() do
    17 * 19 * 7 * 11 * 13 * 3 * 5 * 2
  end

  defmodule Monkey do
    defstruct [:operation, :test, :ontrue, :onfalse, :items, :inspect_count]

    def move_items(%__MODULE__{} = state, modulus) do
      {Enum.map(state.items, &do_step(state, &1, modulus)),
       %{state | items: [], inspect_count: state.inspect_count + length(state.items)}}
    end

    def do_step(%__MODULE__{} = state, item, modulus) do
      item =
        case state.operation do
          ["*", "old"] -> item * item
          ["*", val] -> item * String.to_integer(val)
          ["+", val] -> item + String.to_integer(val)
        end

      item =
        if is_nil(modulus) do
          div(item, 3)
        else
          rem(item, modulus)
        end

      if rem(item, state.test) == 0 do
        {item, state.ontrue}
      else
        {item, state.onfalse}
      end
    end

    def receive_item(%__MODULE__{} = state, item) do
      %{state | items: state.items ++ [item]}
    end
  end

  def solve1(suffix \\ "") do
    data = Input.get_lines(11, suffix)

    monkeys = make_monkeys(data)

    Enum.reduce(1..20, monkeys, &run_round(&1, &2, nil))
    |> Map.values()
    |> Enum.map(& &1.inspect_count)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.reduce(&(&1 * &2))
  end

  def solve2(suffix \\ "") do
    data = Input.get_lines(11, suffix)

    monkeys = make_monkeys(data)
    modulus = Enum.reduce(Map.values(monkeys), 1, &(&1.test * &2))

    Enum.reduce(1..10000, monkeys, &run_round(&1, &2, modulus))
    |> Map.values()
    |> Enum.map(& &1.inspect_count)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.reduce(&(&1 * &2))
  end

  def run_round(_round, monkeys, modulus) do
    monkeys
    |> Map.keys()
    |> Enum.reduce(monkeys, &run_monkey_turn(&1, &2, modulus))
  end

  def run_monkey_turn(monkey_id, monkeys, modulus) do
    {dests, monkey} = Monkey.move_items(monkeys[monkey_id], modulus)

    monkeys =
      Enum.reduce(
        dests,
        monkeys,
        fn {item, dest}, monkeys -> Map.update!(monkeys, dest, &Monkey.receive_item(&1, item)) end
      )

    Map.put(monkeys, monkey_id, monkey)
  end

  def make_monkeys(data) do
    monkeys = Enum.chunk_every(data, 7)
    Enum.map(monkeys, &make_monkey/1) |> Map.new()
  end

  def get_last_word(line) do
    String.split(line, " ") |> Enum.reverse() |> hd
  end

  def make_monkey([id_row, items_row, op_row, test_row, true_row, false_row, ""]) do
    id = id_row |> String.trim(":") |> get_last_word()
    items = String.split(items_row, ": ") |> Enum.at(1) |> Input.to_int_list(", ")
    op = String.split(op_row, "old ") |> Enum.at(1) |> String.split(" ")
    test = test_row |> get_last_word |> String.to_integer()
    ontrue = true_row |> get_last_word()
    onfalse = false_row |> get_last_word()

    {id,
     %Monkey{
       operation: op,
       test: test,
       ontrue: ontrue,
       onfalse: onfalse,
       items: items,
       inspect_count: 0
     }}
  end
end

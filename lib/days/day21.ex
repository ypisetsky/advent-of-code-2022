defmodule Day21 do
  alias __MODULE__.Monkey

  def solve1(suffix \\ "") do
    data = Input.get_lines(21, suffix) |> Enum.map(&Monkey.parse/1) |> Map.new(&{&1.name, &1})
    Monkey.eval(data, "root")
  end

  def solve2(suffix \\ "") do
    data = Input.get_lines(21, suffix) |> Enum.map(&Monkey.parse/1) |> Map.new(&{&1.name, &1})
    root = Map.fetch!(data, "root")
    data = Map.put(data, "root", %{root | op: "-"}) |> Map.delete("humn")

    Monkey.findval(data, "root", 0)
  end

  defmodule Monkey do
    defstruct [:name, :const, :dep1, :dep2, :op]

    def eval(monkeys, me) do
      me = monkeys[me]

      cond do
        is_nil(me) ->
          nil

        me.const != nil ->
          me.const

        true ->
          d1 = eval(monkeys, me.dep1)
          d2 = eval(monkeys, me.dep2)

          if d1 == nil or d2 == nil do
            nil
          else
            case me.op do
              "+" -> d1 + d2
              "-" -> d1 - d2
              "*" -> d1 * d2
              "/" -> d1 / d2
            end
          end
      end
    end

    def findval(_monkeys, "humn", desired) do
      desired
    end

    def findval(monkeys, me, desired) do
      me = monkeys[me]

      if me.const != nil do
        raise "Trying to findval constant #{inspect(monkeys[me])}"
      end

      d1 = eval(monkeys, me.dep1)
      d2 = eval(monkeys, me.dep2)

      case me.op do
        "+" ->
          if d1 == nil do
            findval(monkeys, me.dep1, desired - d2)
          else
            findval(monkeys, me.dep2, desired - d1)
          end

        "-" ->
          if d1 == nil do
            findval(monkeys, me.dep1, desired + d2)
          else
            findval(monkeys, me.dep2, d1 - desired)
          end

        "*" ->
          if d1 == nil do
            findval(monkeys, me.dep1, desired / d2)
          else
            findval(monkeys, me.dep2, desired / d1)
          end

        "/" ->
          if d1 == nil do
            findval(monkeys, me.dep1, desired * d2)
          else
            findval(monkeys, me.dep2, d1 / desired)
          end
      end
    end

    def parse(line) do
      tokens = String.split(line, [" ", ": "])

      if length(tokens) == 2 do
        %__MODULE__{name: Enum.at(tokens, 0), const: String.to_integer(Enum.at(tokens, 1))}
      else
        %__MODULE__{
          name: Enum.at(tokens, 0),
          dep1: Enum.at(tokens, 1),
          op: Enum.at(tokens, 2),
          dep2: Enum.at(tokens, 3)
        }
      end
    end
  end
end

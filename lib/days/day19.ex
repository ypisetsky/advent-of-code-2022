defmodule Day19 do
  require Logger

  alias __MODULE__.Blueprint

  defstruct ore: 0,
            clay: 0,
            obsidian: 0,
            geode: 0,
            orebot: 1,
            claybot: 0,
            obbot: 0,
            geodebot: 0,
            turn: 0

  defmodule Blueprint do
    defstruct [:id, :ore, :clay, :obore, :obclay, :gore, :gobs]
  end

  def solve1(suffix \\ "", n \\ 24) do
    data = Input.get_lines(19, suffix) |> Enum.map(&parseline/1)

    Enum.map(data, &(quality(&1, n) * &1.id)) |> Enum.sum()
  end

  def solve2(suffix \\ "") do
    data = Input.get_lines(19, suffix) |> Enum.map(&parseline/1) |> Enum.take(3)

    Enum.reduce(data, 1, &(quality(&1, 32) * &2))
  end

  def parseline(line) do
    tokens = String.split(line, [" ", ": "])
    get = fn i -> Enum.at(tokens, i) |> String.to_integer() end

    %Blueprint{
      id: get.(1),
      ore: get.(6),
      clay: get.(12),
      obore: get.(18),
      obclay: get.(21),
      gore: get.(27),
      gobs: get.(30)
    }
  end

  def need(_, 0, _), do: 1
  def need(_, _, 0), do: 999
  def need(avail, cost, prod) when avail >= cost, do: 1

  def need(avail, cost, prod) do
    ceil((cost - avail) / prod) + 1
  end

  def next(%{obbot: 0}, {_, _, obcost}, _) when obcost > 0, do: nil
  def next(%{claybot: 0}, {_, claycost, _}, _) when claycost > 0, do: nil

  def next(
        %__MODULE__{} = state,
        {orecost, claycost, obcost} = costs,
        {more, mclay, mob, mgeode} = incs
      ) do

    numturns = min(state.turn, Enum.max([need(state.ore, orecost, state.orebot), need(state.clay, claycost, state.claybot), need(state.obsidian, obcost, state.obbot)]))
    %__MODULE__{
      ore: state.ore + state.orebot * numturns - orecost,
      clay: state.clay + state.claybot * numturns - claycost,
      obsidian: state.obsidian + state.obbot * numturns - obcost,
      geode: state.geode + state.geodebot * numturns,
      orebot: state.orebot + more,
      claybot: state.claybot + mclay,
      obbot: state.obbot + mob,
      geodebot: state.geodebot + mgeode,
      turn: state.turn - numturns
    }
    # cond do
    #   state.turn == 0 ->
    #     state

    #   state.ore >= orecost and state.clay >= claycost and state.obsidian >= obcost ->
    #     %__MODULE__{
    #       ore: state.ore + state.orebot - orecost,
    #       clay: state.clay + state.claybot - claycost,
    #       obsidian: state.obsidian + state.obbot - obcost,
    #       geode: state.geode + state.geodebot,
    #       orebot: state.orebot + more,
    #       claybot: state.claybot + mclay,
    #       obbot: state.obbot + mob,
    #       geodebot: state.geodebot + mgeode,
    #       turn: state.turn - 1
    #     }

    #   true ->
    #     numturns = Enum.min([state.turn, need(state.ore, orecost), need(state.clay, claycost), need(state.obsidian, obcost)])
    #     next(
    #       %__MODULE__{
    #         state
    #         | ore: state.ore + state.orebot * numturns,
    #           clay: state.clay + state.claybot * numturns,
    #           obsidian: state.obsidian + state.obbot,
    #           geode: state.geode + state.geodebot,
    #           turn: state.turn - 1
    #       },
    #       costs,
    #       incs
    #     )
    # end
  end

  def next_possibilities(%__MODULE__{} = state, %Blueprint{} = blueprint) do
      [
        next(state, {blueprint.gore, 0, blueprint.gobs}, {0, 0, 0, 1}),
        (if state.orebot < Enum.max([blueprint.obore,blueprint.clay, blueprint.gore]), do: next(state, {blueprint.ore, 0, 0}, {1, 0, 0, 0})),
        (if state.claybot < blueprint.obclay, do: next(state, {blueprint.clay, 0, 0}, {0, 1, 0, 0})),
        (if state.obbot < blueprint.gobs, do: next(state, {blueprint.obore, blueprint.obclay, 0}, {0, 0, 1, 0}))
      ] |> Enum.reject(&is_nil/1)
  end

  def quality(%Blueprint{} = blueprint, minutes) do
    cacher = Cacher.new()
    ret = walk(%__MODULE__{turn: minutes}, blueprint, cacher)

    Logger.warn(
      "Cached #{inspect(:ets.info(cacher))} items to get #{ret} for #{inspect(blueprint)}"
    )

    Cacher.clean(cacher)

    ret
  end

  def walk(%{turn: 0, geode: geode} = state, _, _) do
    geode
  end

  def walk(%__MODULE__{} = state, %Blueprint{} = blueprint, cacher) do
    Cacher.with_cache(cacher, state, fn ->
      Enum.map(next_possibilities(state, blueprint), &walk(&1, blueprint, cacher)) |> Enum.max()
    end)
  end
end

defmodule Day17 do
  require Logger

  defstruct dropped_pieces: MapSet.new([]),
            max_y: 0,
            to_drop: 2022,
            dropped: 0,
            cursor_to_idx: %{}

  def solve1(suffix \\ "", to_drop) do
    winds = Input.get_lines(17, suffix) |> hd |> String.to_charlist()
    Logger.warn("Wind count is #{Enum.count(winds)}")

    pieces = [
      [{2, 4}, {3, 4}, {4, 4}, {5, 4}],
      [{3, 6}, {2, 5}, {3, 5}, {4, 5}, {3, 4}],
      [{4, 6}, {4, 5}, {4, 4}, {3, 4}, {2, 4}],
      [{2, 7}, {2, 6}, {2, 5}, {2, 4}],
      [{2, 5}, {3, 5}, {2, 4}, {3, 4}]
    ]

    run(%__MODULE__{to_drop: to_drop}, pieces, pieces, winds, winds) |> Map.get(:max_y)
  end

  def solve2(suffix \\ "") do
    winds = Input.get_lines(17, suffix) |> hd |> String.to_charlist()

    pieces = [
      [{2, 4}, {3, 4}, {4, 4}, {5, 4}],
      [{3, 6}, {2, 5}, {3, 5}, {4, 5}, {3, 4}],
      [{4, 6}, {4, 5}, {4, 4}, {3, 4}, {2, 4}],
      [{2, 7}, {2, 6}, {2, 5}, {2, 4}],
      [{2, 5}, {3, 5}, {2, 4}, {3, 4}]
    ]

    {{first_occurrence, first_max_y}, second_occurrence, second_max_y, p, dp} =
      run(%__MODULE__{to_drop: -1000, dropped: 0}, pieces, pieces, winds, winds)

    period = second_occurrence - first_occurrence
    iters = div(1_000_000_000_000 - first_occurrence, period)
    to_go = rem(1_000_000_000_000 - first_occurrence, period)

    Logger.warn(
      "Found a cycle! #{inspect({first_occurrence, first_max_y, second_occurrence, second_max_y, iters, to_go, p, dp})}"
    )

    %{max_y: max_y_rem} = run(%__MODULE__{to_drop: to_go}, pieces, pieces, winds, winds)
    iters * (second_max_y - first_max_y) + max_y_rem + first_max_y
  end

  def run(%__MODULE__{to_drop: 0} = state, _, _, _, _) do
    state
  end

  def run(%__MODULE__{} = state, [], all_pieces, winds, all_winds) do
    run(state, all_pieces, all_pieces, winds, all_winds)
  end

  def run(%__MODULE__{} = state, [piece | pieces], all_pieces, winds, all_winds) do
    placed_piece = piece |> Enum.map(fn {x, y} -> {x, state.max_y + y} end)
    {winds, dropped_piece} = drop(placed_piece, state.dropped_pieces, winds, all_winds)

    {_, piece_max_y} = hd(dropped_piece)

    if Map.has_key?(state.cursor_to_idx, {pieces, winds}) and state.to_drop < 0 do
      {state.cursor_to_idx[{pieces, winds}], state.dropped + 1, max(piece_max_y, state.max_y),
       piece, dropped_piece}
    else
      state = %{
        state
        | to_drop: state.to_drop - 1,
          dropped: state.dropped + 1,
          dropped_pieces:
            MapSet.union(state.dropped_pieces, MapSet.new(dropped_piece)) |> trim(piece_max_y),
          max_y: max(piece_max_y, state.max_y),
          cursor_to_idx:
            Map.put(
              state.cursor_to_idx,
              {pieces, winds},
              {state.dropped + 1, max(piece_max_y, state.max_y)}
            )
      }

      run(state, pieces, all_pieces, winds, all_winds)
    end
  end

  def trim(ms, my) do
    ms |> Enum.filter(fn {_, y} -> y > my - 100 end) |> MapSet.new()
  end

  def drop(piece, dropped_pieces, [], all_winds) do
    drop(piece, dropped_pieces, all_winds, all_winds)
  end

  def drop(piece, dropped_pieces, [wind | winds], all_winds) do
    incr =
      case wind do
        ?> -> {1, 0}
        ?< -> {-1, 0}
      end

    {_did_move, piece} = move(piece, incr, dropped_pieces)
    {did_move, piece} = move(piece, {0, -1}, dropped_pieces)

    # Logger.warn("Stepping piece to #{inspect(piece)} thanks to #{wind} #{inspect(incr)}")

    if did_move do
      drop(piece, dropped_pieces, winds, all_winds)
    else
      {winds, piece}
    end
  end

  def move(piece, {dx, dy}, dropped_pieces) do
    updated_piece = Enum.map(piece, fn {x, y} -> {x + dx, y + dy} end)

    if Enum.any?(updated_piece, &(MapSet.member?(dropped_pieces, &1) or oob(&1))) do
      {false, piece}
    else
      {true, updated_piece}
    end
  end

  def oob({x, y}) do
    y <= 0 or x < 0 or x >= 7
  end
end

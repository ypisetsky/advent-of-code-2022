defmodule Day17 do
  require Logger

  defstruct dropped_pieces: MapSet.new([]),
            max_y: 0,
            to_drop: 2022,
            dropped: 0,
            cursor_to_idx: %{}

  def solve1(suffix \\ "", to_drop) do
    winds = Input.get_lines(17, suffix) |> hd |> String.to_charlist()

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

    {{first_occurrence, first_max_y}, second_occurrence, second_max_y, p, dp, new_pieces,
     new_winds} = run(%__MODULE__{to_drop: -1000, dropped: 0}, pieces, pieces, winds, winds)

    period = second_occurrence - first_occurrence
    iters = div(1_000_000_000_000 - first_occurrence, period)
    to_go = rem(1_000_000_000_000 - first_occurrence, period)

    Logger.warn(
      "Found a cycle! #{inspect({first_occurrence, first_max_y, second_occurrence, second_max_y, iters, to_go, p, dp})}"
    )

    %{max_y: result} =
      run(
        %__MODULE__{
          max_y: iters * (second_max_y - first_max_y) + first_max_y,
          to_drop: to_go,
          dropped_pieces: dp
        },
        new_pieces,
        pieces,
        new_winds,
        winds
      )

    result
  end

  def run(%__MODULE__{to_drop: 0} = state, _, _, _, _) do
    state
  end

  def run(%__MODULE__{} = state, [], all_pieces, winds, all_winds) do
    run(state, all_pieces, all_pieces, winds, all_winds)
  end

  def run(%__MODULE__{} = state, [piece | pieces], all_pieces, winds, all_winds) do
    {winds, dropped_piece} = drop(piece, state.dropped_pieces, winds, all_winds, state.max_y)

    {_, piece_max_y} = hd(dropped_piece)

    {dropped_pieces, new_max_y} =
      merge_pieces(state.dropped_pieces, dropped_piece, state.max_y, piece_max_y)

    if Map.has_key?(state.cursor_to_idx, :erlang.phash2({pieces, winds, dropped_pieces})) and
         state.to_drop < 0 do
      {state.cursor_to_idx[:erlang.phash2({pieces, winds, dropped_pieces})], state.dropped + 1,
       new_max_y, piece, dropped_pieces, pieces, winds}
    else
      state = %{
        state
        | to_drop: state.to_drop - 1,
          dropped: state.dropped + 1,
          dropped_pieces: dropped_pieces,
          max_y: new_max_y,
          cursor_to_idx:
            Map.put(
              state.cursor_to_idx,
              :erlang.phash2({pieces, winds, dropped_pieces}),
              {state.dropped + 1, new_max_y}
            )
      }

      run(state, pieces, all_pieces, winds, all_winds)
    end
  end

  def merge_pieces(dropped_pieces, dropped_piece, old_max_y, piece_max_y) do
    delta = max(piece_max_y, 0)

    new_pieces =
      dropped_piece
      |> Enum.concat(dropped_pieces)
      |> Enum.map(fn {x, y} -> {x, y - delta} end)
      |> Enum.filter(&(elem(&1, 1) > -100))
      |> MapSet.new()

    {new_pieces, old_max_y + delta}
  end

  def drop(piece, dropped_pieces, [], all_winds, max_y) do
    drop(piece, dropped_pieces, all_winds, all_winds, max_y)
  end

  def drop(piece, dropped_pieces, [wind | winds], all_winds, max_y) do
    incr =
      case wind do
        ?> -> {1, 0}
        ?< -> {-1, 0}
      end

    {_did_move, piece} = move(piece, incr, dropped_pieces, max_y)
    {did_move, piece} = move(piece, {0, -1}, dropped_pieces, max_y)

    if did_move do
      drop(piece, dropped_pieces, winds, all_winds, max_y)
    else
      {winds, piece}
    end
  end

  def move(piece, {dx, dy}, dropped_pieces, max_y) do
    updated_piece = Enum.map(piece, fn {x, y} -> {x + dx, y + dy} end)

    if Enum.any?(updated_piece, &(MapSet.member?(dropped_pieces, &1) or oob(&1, max_y))) do
      {false, piece}
    else
      {true, updated_piece}
    end
  end

  def oob({x, y}, max_y) do
    y <= -max_y or x < 0 or x >= 7
  end
end

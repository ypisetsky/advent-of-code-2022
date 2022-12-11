defmodule Day8 do
  def solve1(suffix \\ "") do
    lines = Input.get_lines(8, suffix)
    count = length(lines)

    heights =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, &parse_line/2)

    ret =
      heights
      |> Map.keys()
      |> Enum.filter(&is_visible(count, heights, &1))

    {heights, Enum.count(ret)}
  end

  def solve2(suffix \\ "") do
    lines = Input.get_lines(8, suffix)
    count = length(lines)

    heights =
      lines
      |> Enum.with_index()
      |> Enum.reduce(%{}, &parse_line/2)

    heights
    |> Map.keys()
    |> Enum.map(&scene_score(count, heights, &1))
    |> Enum.max()
  end

  def parse_line({line, idx}, heights) do
    line
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.reduce(heights, fn {val, jdx}, heights -> Map.put(heights, {idx, jdx}, val) end)
  end

  def is_visible(size, heights, {i, j}) do
    [:left, :right, :top, :bottom]
    |> Enum.any?(&visible(size, heights, {i, j}, &1))
  end

  def scene_score(size, heights, pos) do
    Enum.reduce([:left, :right, :top, :bottom], 1, &(scene(size, heights, pos, &1) * &2))
  end

  def candidates(_, {_, 0}, :left), do: []
  def candidates(size, {_, sizem1}, :right) when size == sizem1 + 1, do: []
  def candidates(_, {0, _}, :top), do: []
  def candidates(size, {sizem1, _}, :bottom) when size == sizem1 + 1, do: []

  def candidates(size, {i, j}, :left) do
    (j - 1)..0
    |> Enum.map(&{i, &1})
  end

  def candidates(size, {i, j}, :right) do
    (j + 1)..(size - 1)
    |> Enum.map(&{i, &1})
  end

  def candidates(size, {i, j}, :top) do
    (i - 1)..0
    |> Enum.map(&{&1, j})
  end

  def candidates(size, {i, j}, :bottom) do
    (i + 1)..(size - 1)
    |> Enum.map(&{&1, j})
  end

  def visible(size, heights, pos, dir) do
    candidates(size, pos, dir) |> Enum.all?(&(heights[&1] < heights[pos]))
  end

  def scene(size, heights, pos, dir) do
    c = candidates(size, pos, dir)

    ret =
      c
      |> Enum.take_while(&(heights[&1] < heights[pos]))
      |> Enum.count()

    if ret < length(c) do
      ret + 1
    else
      ret
    end
  end
end

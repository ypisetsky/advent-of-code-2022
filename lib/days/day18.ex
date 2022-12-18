defmodule Day18 do
  def neighbors({x,y,z}, cb) do
    [
      {x+1, y, z},
      {x-1, y, z},
      {x, y+1, z},
      {x, y-1, z},
      {x, y, z-1},
      {x, y, z+1}
    ] |> Enum.filter(cb)
  end

  def parse_line(line) do
    [x, y, z] = Input.to_int_list(line, ",")
    {x, y, z}
  end

  def solve1(suffix \\ "") do
    data = Input.get_lines(18, suffix) |> Enum.map(&parse_line/1) |> MapSet.new()

    Enum.map(data, fn point -> 6 - Enum.count(neighbors(point, &MapSet.member?(data, &1))) end)
    |> Enum.sum()
  end

  def solve2(suffix \\ "") do
    data = Input.get_lines(18, suffix) |> Enum.map(&parse_line/1) |> MapSet.new()
    min_x = data |> Enum.map(&elem(&1, 0)) |> Enum.min()
    min_y = data |> Enum.map(&elem(&1, 1)) |> Enum.min()
    min_z = data |> Enum.map(&elem(&1, 2)) |> Enum.min()

    max_x = data |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = data |> Enum.map(&elem(&1, 1)) |> Enum.max()
    max_z = data |> Enum.map(&elem(&1, 2)) |> Enum.max()
    exterior = make_exterior(min_x - 1, min_y- 1, min_z- 1, max_x + 1, max_y + 1, max_z + 1, data)
    Enum.map(data, fn point -> Enum.count(neighbors(point, &MapSet.member?(exterior, &1))) end)
    |> Enum.sum()
  end

  def make_exterior(minx, miny, minz, maxx, maxy, maxz, lava) do
    src = {minx, miny, minz}
    bfs(MapSet.new([src]), :queue.in(src, :queue.new()), lava, minx..maxx, miny..maxy, minz..maxz)
  end

  def bfs(found, queue, lava, xbounds, ybounds, zbounds) do
    case :queue.out(queue) do
      {{:value, point}, queue} ->
        newfound = neighbors(point, &(not MapSet.member?(lava, &1) and not MapSet.member?(found, &1) and in_bounds(&1, xbounds, ybounds, zbounds)))
        queue = Enum.reduce(newfound, queue, &:queue.in/2)
        found = Enum.reduce(newfound, found, &MapSet.put(&2, &1))
        bfs(found, queue, lava, xbounds, ybounds, zbounds)

      {:empty, _queue} -> found
    end
  end

  def in_bounds({x, y, z}, xbounds, ybounds, zbounds) do
    x in xbounds and y in ybounds and z in zbounds
  end
end

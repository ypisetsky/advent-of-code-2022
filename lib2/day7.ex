defmodule Day7 do
  require Logger

  def solve1(suffix \\ "") do
    lines = Input.get_lines(7, suffix)
    cmds = Enum.map(lines, &parse/1)

    sizes = walk(cmds, [], %{})

    sizes
    |> Map.values()
    |> Enum.filter(&(&1 <= 100_000))
    |> Enum.sum()
  end

  def solve2(suffix \\ "") do
    lines = Input.get_lines(7, suffix)
    cmds = Enum.map(lines, &parse/1)

    sizes = walk(cmds, [], %{})

    to_free = sizes[["/"]] - 40_000_000

    sizes
    |> Map.values()
    |> Enum.filter(&(&1 >= to_free))
    |> Enum.sort()
    |> hd
  end

  def parse(line) do
    cond do
      String.contains?(line, "$ cd ..") -> :cd_up
      String.contains?(line, "$ cd ") -> {:cd_down, String.slice(line, 5, 100)}
      String.contains?(line, "dir ") -> :dir
      line == "$ ls" -> :ls
      true -> {:file, String.split(line, " ")}
    end
  end

  def walk([], _path, path_size_map) do
    path_size_map
  end

  def walk([:dir | cmds], path, path_size_map) do
    walk(cmds, path, path_size_map)
  end

  def walk([:ls | cmds], path, path_size_map) do
    walk(cmds, path, path_size_map)
  end

  def walk([:cd_up | cmds], [cwd | path], path_size_map) do
    walk(cmds, path, path_size_map)
  end

  def walk([{:cd_down, dir} | cmds], path, path_size_map) do
    walk(cmds, [dir | path], path_size_map)
  end

  def walk([{:file, [size, name]} | cmds], path, path_size_map) do
    path_size_map = attach_to_all(String.to_integer(size), path, path_size_map)

    walk(cmds, path, path_size_map)
  end

  def attach_to_all(_, [], path_size_map) do
    path_size_map
  end

  def attach_to_all(size, [cwd | parent_path] = path, path_size_map) do
    attach_to_all(size, parent_path, Map.update(path_size_map, path, size, &(&1 + size)))
  end
end

defmodule Input do
  require Logger

  def get_lines(day, suffix \\ "") do
    Logger.warn("#{path_prefix()}/input/day#{day}#{suffix}.txt")
    {:ok, data} = File.read("#{path_prefix()}/input/day#{day}#{suffix}.txt")
    String.split(data, "\n")
  end

  def to_int_list(str, split \\ " ") do
    str
    |> String.split(split)
    |> Enum.map(&String.to_integer/1)
  end

  defp path_prefix() do
    Application.get_env(:advent_of_code, :path_prefix)
  end
end

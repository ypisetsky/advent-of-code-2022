defmodule Day3 do
    require Logger

    def solve1(suffix \\ "") do
        Input.get_lines(3, suffix)
            |> Enum.map(&get_score_v2/1)
            |> Enum.sum()
    end

    def solve2(suffix \\ "") do
        Input.get_lines(3, suffix)
            |> Enum.chunk_every(3)
            |> Enum.map(&score_part2/1)
            |> Enum.sum()
    end

    def to_compartments(line) do
        all_chars = String.to_charlist(line)
        Enum.split(all_chars, div(length(all_chars), 2))
    end

    def get_score(line) do
        {a, b} = to_compartments(line)
        bmap = MapSet.new(b)
        unique_a = MapSet.new(a)
        Enum.reduce(unique_a, 0, fn c, acc -> 
            if MapSet.member?(bmap, c) do
                acc + charscore(c)
            else
                acc
            end
        end)
    end

    def get_score_v2(line) do
        intersection = line
            |> to_compartments()
            |> Tuple.to_list()
            |> common()
            |> Enum.map(&charscore/1)
            |> Enum.sum()
    end

    def common(parts) do
        Enum.reduce(parts, fn new, accset ->
            MapSet.intersection(MapSet.new(new), MapSet.new(accset))
        end)
    end


    def score_part2(lines) do
        lines
            |> Enum.map(&String.to_charlist/1)
            |> common()
            |> Enum.map(&charscore/1)
            |> Enum.sum()
    end

    def charscore(c) when c >= ?a and c <= ?z, do: c - ?a + 1

    def charscore(c) when c >= ?A and c <= ?Z, do: c - ?A + 27
end
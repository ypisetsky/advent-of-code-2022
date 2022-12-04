defmodule Day4 do
    def solve1(suffix \\ "") do
        solve(&is_subset/1, suffix)
    end

    def solve2(suffix \\ "") do
        solve(&has_overlap/1, suffix)
    end

    def solve(cb, suffix \\ "") do
        lines = Input.get_lines(4, suffix)
        lines
            |> Enum.filter(cb)
            |> Enum.count()
    end

    def is_subset(line) do
        {ma,mb} = parse(line)
        MapSet.intersection(ma,mb) in [ma, mb]
    end

    def has_overlap(line) do
        {ma,mb} = parse(line)
        not MapSet.disjoint?(ma,mb)
    end

    def parse(line) do
        [a1,a2,b1,b2] = Input.to_int_list(line, [",","-"])
        {MapSet.new(a1..a2),MapSet.new(b1..b2)}
    end
end
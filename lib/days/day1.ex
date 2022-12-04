defmodule Day1 do
    def get_elves(suffix \\ "") do
        lines = Input.get_lines(1, suffix)
        {elves, _} = Enum.reduce(lines ++ [""], {[], 0}, fn 
            "", {elves, current_elf} -> {[current_elf | elves], 0}
            line, {elves, current_elf} -> {elves, current_elf + hd(Input.to_int_list(line))}
        end)
        elves
    end

    def solve1(suffix \\ "") do
        Enum.max(get_elves(suffix))
    end

    def solve2(suffix \\ "") do
        suffix 
            |> get_elves()
            |> Enum.sort(:desc)
            |> Enum.take(3)
            |> Enum.sum()
    end
end
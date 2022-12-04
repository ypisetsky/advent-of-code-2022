defmodule Day2 do
    def score(line) do
        [opp, you] = String.split(line, " ") |> Enum.map(&normalize/1)
        score(opp, you)
    end

    def score2(line) do
        [opp, you] = String.split(line, " ")

        result_score = case you do
            "X" -> 0
            "Y" -> 1
            "Z" -> 2
        end
        
        choice_score = cond do
            you == "Z" and opp == "C" -> 1
            you == "X" and opp == "A" -> 3
            true -> val(opp) + result_score - 1
        end

        choice_score + 3 * result_score
    end

    def normalize("X"), do: "A"
    def normalize("Y"), do: "B"
    def normalize("Z"), do: "C"
    def normalize(other), do: other

    def val("A"), do: 1
    def val("B"), do: 2
    def val("C"), do: 3

    def score(same, same), do: 3 + val(same)
    def score("A", "B"), do: 8
    def score("B", "C"), do: 9
    def score("C", "A"), do: 7
    def score(opp, you), do: val(you)

    def solve1(suffix \\ "") do
        Input.get_lines(2, suffix)
            |> Enum.map(&score/1)
            |> Enum.sum()
    end

    def solve2(suffix \\ "") do
        Input.get_lines(2, suffix)
            |> Enum.map(&score2/1)
            |> Enum.sum()
    end
end
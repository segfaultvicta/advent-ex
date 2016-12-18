defmodule Advent.Sixteen.Eighteen do
  alias Advent.Helpers.Utility, as: U
  use Timing

  @input "^.^^^..^^...^.^..^^^^^.....^...^^^..^^^^.^^.^^^^^^^^.^^.^^^^...^^...^^^^.^.^..^^..^..^.^^.^.^......."
  #@input ".^^.^.^^^^"

  @mapdepth 400000
  #@mapdepth 10

  @rowlength 100
  #@rowlength 10

  def safety_dance(prev) do
    cond do
      prev == "^^." -> "^"
      prev == ".^^" -> "^"
      prev == "^.." -> "^"
      prev == "..^" -> "^"
      true -> "."
    end
  end

  def safe_or_trap(position, lastrow) do
    left = if position == 0 do "." else String.slice(lastrow, position - 1, 1) end
    centre = String.slice(lastrow, position, 1)
    right = if position == @rowlength - 1 do "." else String.slice(lastrow, position + 1, 1) end
    safety_dance(left <> centre <> right)
  end

  def buildmap(input, length) do
    Enum.reduce(1..@mapdepth-1, [input, [input]], fn(e, [lastrow, map]) ->
      IO.puts e
      row = Enum.reduce(0..@rowlength-1, "", fn(index, string) ->
        string <> safe_or_trap(index, lastrow)
      end)
      [row, [row|map]]
    end)
    |> List.flatten
    |> tl
    |> Enum.reverse
  end

  def a do
    {elapsed, result} = time do
      map = buildmap(@input, @rowlength)
      countsafe = Enum.join(map, "") |> String.codepoints
      |> Enum.reduce(0, fn(x, acc) -> if x == "." do acc+1 else acc end end)
      #displaymap = Enum.join(map, "\n")
      #IO.puts displaymap
      {:ok, countsafe}
    end
  end

  def b do
    {elapsed, result} = time do
      map = Enum.join(buildmap(@input, @rowlength), "\n")
    end
  end

end

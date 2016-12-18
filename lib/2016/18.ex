defmodule Advent.Sixteen.Eighteen do
  alias Advent.Helpers.Utility, as: U
  use Timing

  @input "^.^^^..^^...^.^..^^^^^.....^...^^^..^^^^.^^.^^^^^^^^.^^.^^^^...^^...^^^^.^.^..^^..^..^.^^.^.^......."
  #@input ".^^.^.^^^^"

  @mapdepth 400000
  #@mapdepth 10

  @rowlength 100
  #@rowlength 10

  def safe_or_trap(position, lastrow) do
    #U.i position, "   safe_or_trap position"
    #U.i vec_to_string(lastrow), "    safe_or_trap lastrow"
    left = if position == 0 do true else lastrow[position - 1] end
    right = if position == @rowlength - 1 do true else lastrow[position + 1] end
    #U.i left, "    left"
    #U.i right, "    right"
    if left == right do true else false end
  end

  def buildmap(input, length) do
    #U.i vec_to_string(input), "original input to buildmap"
    Enum.reduce(1..@mapdepth-1, [input, input], fn(e, [lastrow, map]) ->
      #IO.puts e
      #U.i vec_to_string(lastrow), "lastrow"
      row = Enum.reduce(0..@rowlength-1, [], fn(index, rowvec) ->
        #U.i index, "  column index"
        #U.i row_to_string(rowvec), "  rowvec at this point"
        [safe_or_trap(index, lastrow)|rowvec]
      end)
      |> Enum.reverse
      |> Vector.new
      #U.i vec_to_string(row), "row"
      #IO.puts "\n"
      [row, [row|map]]
    end)
    |> U.squish([]) |> tl
    |> Enum.reverse
  end

  def vec_to_string(vec), do: Vector.to_list(vec) |> row_to_string
  def row_to_string(list) do
    Enum.map(list, fn(x) -> if x do "." else "^" end end) |> Enum.join
  end

  def vectorise(input) do
    input |> to_charlist
    |> Enum.map(fn(x) -> if x == ?. do true else false end end)
    |> Vector.new
  end

  def a do
    {elapsed, result} = time do
      map = buildmap(vectorise(@input), @rowlength) |> Enum.map(&vec_to_string/1)
      #Enum.join(map, "\n") |> IO.puts

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

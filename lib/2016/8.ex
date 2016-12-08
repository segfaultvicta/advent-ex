defmodule AdventOfCode.Y16.D8 do

  @input "./input/2016/8"

  def parse_input(line) do
    line = String.strip(line)
    cond do
      match = Regex.run(~R/^rect (\d+)x(\d+)/, line) ->
        [_, x, y] = match
        %{type: :rect, x: String.to_integer(x), y: String.to_integer(y)}
      match = Regex.run(~R/^rotate row y=(\d+) by (\d+)/, line) ->
        [_, y, magnitude] = match
        %{type: :rotate, orientation: :row, y: String.to_integer(y), magnitude: String.to_integer(magnitude)}
      match = Regex.run(~R/^rotate column x=(\d+) by (\d+)/, line) ->
        [_, x, magnitude] = match
        %{type: :rotate, orientation: :col, x: String.to_integer(x), magnitude: String.to_integer(magnitude)}
      true ->
        %{type: :wtf}
    end
  end

  # should probably extract this out somewhere
  def from_list(list) when is_list(list) do
    _from_list(list)
  end
  defp _from_list(list, map \\ %{}, index \\ 0)
  defp _from_list([], map, _index), do: map
  defp _from_list([h|t], map, index) do
    map = Map.put(map, index, _from_list(h))
    _from_list(t, map, index + 1)
  end
  defp _from_list(other, _, _), do: other

  def generate_initial_bitmap(cols, rows) do
    List.duplicate(0,cols)
    |> List.duplicate(rows)
    |> from_list
  end

  # Light up the pixels in a box from (0,0) in the upper left to (x,y)
  def light_rectangles(bitmap, x, y) do
    #IO.puts "Lighting rectangles from 0,0 to #{x},#{y}"
    (for col <- 0..x-1, do: col)
    |> Enum.reduce(bitmap, fn(col, bitmap) -> 
      (for row <- 0..y-1, do: row)
      |> Enum.reduce(bitmap, fn(row, bitmap) ->
        put_in bitmap[row][col], 1
      end)
    end)
  end

  def rotate_list_left(list, 0), do: list
  def rotate_list_left([head|tail], magnitude), do: rotate_list_left(tail ++ [head], magnitude - 1)
  def rotate_list_right(list, magnitude), do: list |> Enum.reverse |> rotate_list_left(magnitude) |> Enum.reverse

  def rotate_column(bitmap, col, magnitude) do
    numRows = length(Map.values(bitmap))
    steps = rem magnitude, numRows
    column = (for row <- 0..numRows-1, do: row)
    |> Enum.reduce([], fn(row, acc) ->
      acc = [bitmap[row][col]|acc]
    end)
    |> Enum.reverse
    |> rotate_list_right(magnitude)
    |> List.to_tuple
    (for row <- 0..numRows-1, do: row)
    |> Enum.reduce(bitmap, fn(row, acc) ->
      put_in acc[row][col], (column |> elem(row))
    end)
  end

  def rotate_row(bitmap, row, magnitude) do
    row_rotated = bitmap[row] 
    |> Enum.sort
    |> Enum.map(fn({col, value}) -> [value] end)
    |> List.flatten
    |> rotate_list_right(magnitude)
    |> List.to_tuple
    (for col <- 0..tuple_size(row_rotated)-1, do: col)
    |> Enum.reduce(bitmap, fn(col, acc) ->
      put_in acc[row][col], row_rotated |> elem(col)
    end)
  end

  def bitmap_step(step, bitmap) do
    prettyprint(bitmap, 50, 6)
    :timer.sleep(50)
    case step.type do
      :rect ->
        light_rectangles(bitmap, step.x, step.y)
      :rotate ->
        case step.orientation do
          :col ->
            rotate_column(bitmap, step.x, step.magnitude)
          :row ->
            rotate_row(bitmap, step.y, step.magnitude)
        end
    end
  end

  def prettyprint(map, cols, rows) do
    (for r <- 0..rows-1, do: r)
    |> Enum.reduce("", fn(row, acc) ->
      "#{acc}#{prettyprint_row(map[row], cols)}\n"
    end)
    |> IO.puts
  end

  def prettyprint_row(row, cols) do
    (for c <- 0..cols-1, do: c)
    |> Enum.reduce("", fn(col, acc) ->
      "#{acc}#{row[col]} "
    end)
  end

  def a do
    File.stream!(@input)
    |> Enum.map(&parse_input/1)
    |> Enum.reduce(generate_initial_bitmap(50, 6), &bitmap_step/2)
    |> Enum.reduce(0, fn(bitmap, acc) -> 
      0 # I was REALLY tired at this point and didn't feel like figuring this out, lol, so I just counted :D
    end)
  end

  def b do
    File.stream!(@input)
  end

end

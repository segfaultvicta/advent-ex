defmodule Advent.Sixteen.TinyLCD do
  alias Advent.Agents.Screen

  def init(width, height) do
    Screen.init(width, height)
  end

  def update(%{type: :rect, x: x, y: y}) do
    for i <- 0..(x - 1)  do
      for j <- 0..(y - 1)  do
        Screen.set i, j, "█"
      end
    end
  end

  def update(%{type: :rotate, orientation: :row, y: y, magnitude: magnitude }) do
    row_rotated = Screen.curr
    |> Matrix.row(y)
    |> Advent.Helpers.List.rotate_right(magnitude)
    |> Vector.from_list
    for col <- 0..Vector.length(row_rotated) - 1 do
      Screen.set(col, y, row_rotated[col])
    end
  end

  def update(%{type: :rotate, orientation: :col, x: x, magnitude: magnitude }) do
    col_rotated = Screen.curr
    |> Matrix.column(x)
    |> Advent.Helpers.List.rotate_right(magnitude)
    |> Vector.from_list
    for row <- 0..Vector.length(col_rotated) - 1 do
      Screen.set(x, row, col_rotated[row])
    end
  end

  def tostring do
    Screen.curr
    |> Matrix.to_list
    |> Enum.map(&(Enum.join(&1)))
    |> Enum.join("\n")
  end

  def prettyprint do
    IO.puts tostring
  end

  def lit do
    tostring
    |> String.graphemes
    |> Enum.count(&(&1 == "█"))
  end
end

defmodule Advent.Sixteen.Eight do
  alias Advent.Sixteen.TinyLCD

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

  def bitmap_step(step) do
    TinyLCD.prettyprint
    :timer.sleep(50)
    TinyLCD.update(step)
  end

  def a do
    TinyLCD.init(50, 6)
    File.stream!(@input)
    |> Enum.map(&parse_input/1)
    |> Enum.each(&(bitmap_step(&1)))
    TinyLCD.lit
  end

  def b do
  end

end

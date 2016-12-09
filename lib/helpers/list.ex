defmodule Advent.Helpers.List do
  def rotate_left(list, 0), do: list
  def rotate_left([head|tail], magnitude), do: rotate_left(tail ++ [head], magnitude - 1)
  def rotate_right(list, magnitude), do: list |> Enum.reverse |> rotate_left(magnitude) |> Enum.reverse
end

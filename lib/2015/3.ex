defmodule Advent.Fifteen.Three do

  @input "./input/2015/3"

  def visit(step, acc) do
    [[x, y]|_] = acc
    do_visit(step, acc, x, y)
  end

  defp do_visit("<", acc, x, y), do: [[x - 1, y]|acc]
  defp do_visit("v", acc, x, y), do: [[x, y - 1]|acc]
  defp do_visit(">", acc, x, y), do: [[x + 1, y]|acc]
  defp do_visit("^", acc, x, y), do: [[x, y + 1]|acc]

  def a do
    File.read!(@input)
    |> String.strip
    |> String.graphemes
    |> Enum.reduce([[0, 0]], &visit/2)
    |> Enum.uniq
    |> Enum.count
  end

  def b do
    File.stream!(@input)
  end

end

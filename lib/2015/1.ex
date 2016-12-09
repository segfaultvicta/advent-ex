defmodule Advent.Fifteen.One do

  @input "./input/2015/1"

  def handle_floor(floor, acc) do
    case floor do
      "(" -> acc + 1
      ")" -> acc - 1
    end
  end

  def find_basement(floor, acc) do
    case acc do
      {-1, step} -> step
      {curr, step} -> case floor do
        "(" -> {curr + 1, step + 1}
        ")" -> {curr - 1, step + 1}
      end
      n -> n
    end
  end

  def a do
    File.read!(@input)
    |> String.strip
    |> String.codepoints
    |> Enum.reduce(0, &handle_floor/2)
  end

  def b do
    File.read!(@input)
    |> String.strip
    |> String.codepoints
    |> Enum.reduce({0,0}, &find_basement/2)
  end

end

defmodule Advent.Sixteen.Nineteen do
  alias Advent.Helpers.Utility, as: U
  use Timing

  @input 3004953
  #@input 5

  def eliminate([elf]), do: elf
  def eliminate(elves) when length(elves) > 1 do
    #U.i elves, "elves"
    if rem(length(elves), 2) == 0 do
      eliminate(Enum.take_every(elves,2))
    else
      [last|rest] = Enum.reverse(Enum.take_every(elves,2))
      eliminate([last|Enum.reverse(rest)])
    end
  end

  def a do
    {elapsed, result} = time do
      eliminate(Enum.reduce(1..@input, [], fn(i, acc) -> [i|acc] end) |> Enum.reverse)
    end
  end

  def b do
    {elapsed, result} = time do
    end
  end

end

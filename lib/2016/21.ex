defmodule Advent.Sixteen.Twentyone do
  alias Advent.Helpers.Utility, as: U
  use Timing

  @input './input/2016/21'

  def prepare_input do
    File.stream!(@input)
    |> Enum.reduce([], fn(line, acc) ->
      [String.trim(line)|acc]
    end)
  end

  def a do
    {elapsed, result} = time do
      prepare_input
    end
  end

  def b do
    {elapsed, result} = time do
    end
  end

end

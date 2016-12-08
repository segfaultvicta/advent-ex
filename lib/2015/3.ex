defmodule AdventOfCode.Y15.D3 do

  @input "./input/2015/3"

  def a do
    File.stream!(@input)
    |> String.codepoints
  end

  def b do
    File.stream!(@input)
  end

end

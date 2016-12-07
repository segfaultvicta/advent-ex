defmodule AdventOfCode.Y15.D2 do

  @input "./input/2015/2"

  def line_to_dimensions_list(line) do
    #String.split(String.strip(line), "x")
    String.strip(line)
    |> String.split("x")
    |> Enum.map fn(dim) -> String.to_integer(dim) end
  end

  def dims_to_surface_area([length, width, height]) do
    2*length*width + 2*width*height + 2*height*length + Enum.min([length*width, width*height, height*length])
  end

  def ribbon_required_for([shortest, medium, biggest]) do
    2*shortest + 2*medium + shortest*medium*biggest
  end

  def a do
    File.stream!(@input)
    |> Enum.map(&line_to_dimensions_list/1)
    |> Enum.map(&dims_to_surface_area/1)
    |> Enum.sum
  end

  # alternately, with anonymous functions:
  def a_2 do
    File.stream!(@input)
    |> Enum.map(fn(line) ->
      String.strip(line)
      |> String.split("x")
      |> Enum.map(fn(dim) ->
        String.to_integer(dim)
      end)
    end)
    |> Enum.map(fn([len, wid, hei]) ->
      2*len*wid + 2*wid*hei + 2*hei*len + Enum.min([len*wid, wid*hei,hei*len])
    end)
    |> Enum.sum
  end

  def b do
    File.stream!(@input)
    |> Enum.map(&line_to_dimensions_list/1)
    |> Enum.map(&Enum.sort/1)
    |> Enum.map(&ribbon_required_for/1)
    |> Enum.sum
  end

end

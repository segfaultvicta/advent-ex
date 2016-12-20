defmodule Advent.Sixteen.Twenty do
  alias Advent.Helpers.Utility, as: U
  use Timing

  @input './input/2016/20'

  @fakeinput [[5,8],[0,2],[4,7]]

  def a do
    {elapsed, result} = time do
      blacklist = File.stream!(@input)
      |> Enum.reduce([], fn(line, blacklist) ->
        [String.trim(line) |> String.split("-") |> Enum.map(&String.to_integer/1)|blacklist]
      end)
      U.i blacklist, "blacklist"
      Enum.find(1..4294967295, fn(i) ->
        not Enum.any?(blacklist, fn([low,high]) ->
          low <= i and i <= high
        end)
      end)
    end
  end

  def b do
    {elapsed, result} = time do
      blacklist = File.stream!(@input)
      |> Enum.reduce([], fn(line, blacklist) ->
        [String.trim(line) |> String.split("-") |> Enum.map(&String.to_integer/1)|blacklist]
      end)
      U.i blacklist, "blacklist"
      blacklistmap = Enum.reduce(blacklist, MapSet.new, fn([low, high], mapset) ->
        for i <- low..high do MapSet.put(mapset, i) end
      end)
      U.i blacklistmap, "blacklistmap"
      #Enum.count(1..4294967295, fn(i) ->
      #  not Enum.any?(blacklist, fn([low,high]) ->
      #    low <= i and i <= high
      #  end)
      #nd)
    end
  end

end

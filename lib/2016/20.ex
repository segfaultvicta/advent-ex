defmodule Advent.Sixteen.Twenty do
  alias Advent.Helpers.Utility, as: U
  use Timing

  @input './input/2016/20'

  def a do
    {elapsed, result} = time do
      blacklist = File.stream!(@input)
      |> Enum.reduce([], fn(line, blacklist) ->
        [String.trim(line) |> String.split("-") |> Enum.map(&String.to_integer/1)|blacklist]
      end)
      [_, first] = Enum.reduce(blacklist, [], fn([low,high],acc) ->
        [%{bound: :low, value: low},%{bound: :high, value: high}|acc]
      end) |> Enum.sort_by(fn(x) -> x.value end)
      |> filter_for_contained_subgroups |> Enum.sort_by(fn(x) -> x.value end)
      |> combine_adjacent_blacklists |> Enum.sort_by(fn(x) -> x.value end)
      |> Enum.take(2)
      first.value
    end
  end

  def do_filter_for_contained_subgroups(filtered_blacklist, [], _, _), do: filtered_blacklist

  def do_filter_for_contained_subgroups(filtered_blacklist, [next|blacklist], nestlevel, savedlower) do
    nestlevel = if next.bound == :low do nestlevel + 1 else nestlevel - 1 end
    cond do
      nestlevel == 1 and savedlower == :init ->
        savedlower = next.value
      nestlevel == 0 ->
        filtered_blacklist = [%{bound: :low, value: savedlower},%{bound: :high, value: next.value}|filtered_blacklist]
        savedlower = :init
      true ->
    end
    do_filter_for_contained_subgroups(filtered_blacklist, blacklist, nestlevel, savedlower)
  end

  def filter_for_contained_subgroups(blacklist) do
    do_filter_for_contained_subgroups([], blacklist, 0, :init)
  end

  def combine_adjacent_blacklists([low,high]), do: [low,high]
  def combine_adjacent_blacklists([low,high,low2,high2|blacklist]) do
    if high.value + 1 == low2.value do
      combine_adjacent_blacklists([%{bound: :low,value: low.value}, %{bound: :high, value: high2.value}|blacklist])
    else
      [low,high|combine_adjacent_blacklists([low2,high2|blacklist])]
    end
  end

  def b do
    {elapsed, result} = time do
      blacklist = File.stream!(@input)
      |> Enum.reduce([], fn(line, blacklist) ->
        [String.trim(line) |> String.split("-") |> Enum.map(&String.to_integer/1)|blacklist]
      end)
      blacklist = Enum.reduce(blacklist, [], fn([low,high],acc) ->
        [%{bound: :low, value: low},%{bound: :high, value: high}|acc]
      end) |> Enum.sort_by(fn(x) -> x.value end)
      |> filter_for_contained_subgroups |> Enum.sort_by(fn(x) -> x.value end)
      |> combine_adjacent_blacklists |> Enum.sort_by(fn(x) -> x.value end)
      |> Enum.chunk(2, 1) |> Enum.drop_every(2)
      |> Enum.map(fn([high,low]) -> low.value - (high.value + 1) end)
      |> Enum.sum
    end
  end

end

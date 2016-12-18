defmodule Advent.Helpers.Utility do
  def i(thing, string) do
    IO.puts string <> ": " <> inspect thing
    thing
  end

  def i(thing) do
    i(thing, "something")
  end

  def squish(term, acc) when not is_list(term), do: [term|acc]
  def squish([], acc), do: acc
  def squish([h,rest], acc) do
    [h|squish(rest, acc)]
  end
  def squish([h|t], acc) do
    [h|squish(t, acc)]
  end
end

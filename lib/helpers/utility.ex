defmodule Advent.Helpers.Utility do
  def i(thing, string) do
    IO.puts string <> ": " <> inspect thing
    thing
  end

  def i(thing) do
    i(thing, "something")
  end
end

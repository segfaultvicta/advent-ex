defmodule Advent.Sixteen.Sixteen do
  alias Advent.Helpers.Utility, as: U
  use Timing
  import DefMemo

  @input "10001001100000001"
  #@input "10000"

  @length 272
  #@length 20

  def dragon(charlist, length) when length(charlist) < length do
    reverse = Enum.reverse(charlist)
    |> Enum.map(fn(x) -> if x == ?0 do ?1 else ?0 end end)
    dragon(charlist ++ [?0] ++ reverse, length)
  end

  def dragon(charlist, length) when length(charlist) > length do
    charlist |> to_string |> String.slice(0, length) |> to_charlist
  end

  def chunk_lookup([h,t]) do
    if h == t do ?1 else ?0 end
  end

  # even
  def checksum(dragon) when rem(length(dragon), 2) == 0 do
    Enum.chunk(dragon, 2)
    |> Enum.map(&chunk_lookup/1)
    |> checksum
  end

  # odd
  def checksum(dragon) when (rem(length(dragon), 2) != 0), do: dragon

  def a do
    {elapsed, result} = time do
      dragon(@input |> to_charlist, @length)
      |> checksum
    end
  end

  def b do
    {elapsed, result} = time do
      dragon(@input |> to_charlist, 35651584)
      |> checksum
    end
  end

end

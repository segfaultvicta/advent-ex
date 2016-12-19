defmodule Advent.Sixteen.Fifteen do
  alias Advent.Helpers.Utility, as: U
  use Timing

  def divstream(start, period, rowcorrection) do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.filter(&(rem(&1,period) == 0))
    |> Stream.map(&(&1 + (period - start)))
    |> Stream.map(&(&1 - rowcorrection))
    |> Stream.filter(&(&1 > 0))
  end

  def fallthrough(start, period, rowcorrection, timestamp) do
    rem(((timestamp + rowcorrection) - (period - start)),period) == 0
  end

  def a do
    {elapsed, result} = time do
      Enum.take_while(1..17000, fn(x) ->
        fallthrough(5,17,1,x) and
        fallthrough(8,19,2,x) and
        fallthrough(1, 7,3,x) and
        fallthrough(7,13,4,x) and
        fallthrough(1, 5,5,x) and
        fallthrough(0, 3,6,x)
      end)
    end
  end

  def b do
    {elapsed, result} = time do
      # BLUH BLUH EIGHT-HOUR RUNTIMES, THEY SAID. O(N) COMPLEXITY, THEY SAID.
    end
  end

end

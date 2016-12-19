defmodule Advent.Sixteen.Fifteen do
  alias Advent.Helpers.Utility, as: U
  use Timing

  def fallthrough(start, period, rowcorrection, timestamp) do
    rem(((timestamp + rowcorrection) - (period - start)),period) == 0
  end

  def a do
    {elapsed, result} = time do
      Enum.find(1..17000, fn(x) ->
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
      # "BLUH BLUH EIGHT-HOUR RUNTIMES", THEY SAID. "O(N) COMPLEXITY", THEY SAID.
      Enum.find(1..5000000, fn(x) ->
        fallthrough(5,17,1,x) and
        fallthrough(8,19,2,x) and
        fallthrough(1, 7,3,x) and
        fallthrough(7,13,4,x) and
        fallthrough(1, 5,5,x) and
        fallthrough(0, 3,6,x) and
        fallthrough(0,11,7,x)
      end)
    end
  end

end

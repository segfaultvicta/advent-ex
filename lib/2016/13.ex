defmodule Advent.Sixteen.Thirteen.State do
  alias Advent.Helpers.Utility, as: U
  alias Advent.Sixteen.Thirteen.State

  @favourite_number 1364
  #@favourite_number 10

  defstruct [:x, :y]

  def to_list(state) do
    [state.x, state.y]
  end

  def valid(state) do
    x = state.x
    y = state.y
    (x >= 0 && y >= 0) and (Integer.to_string(@favourite_number + x*x + 3*x + 2*x*y + y + y*y, 2)
    |> to_charlist |> Enum.count(fn(x) -> x == ?1 end)
    |> rem(2)) == 0
  end

  def successors(state) do
    nesw = [%State{x: state.x - 1, y: state.y},
            %State{x: state.x, y: state.y - 1},
            %State{x: state.x + 1, y: state.y},
            %State{x: state.x, y: state.y + 1}]
    Enum.filter(nesw, &State.valid/1)
  end

  def canonicalise(state) do
    state
  end
end

defmodule Advent.Sixteen.Thirteen do
  alias Advent.Helpers.NodeCache, as: Cache
  alias Advent.Sixteen.Thirteen.State
  alias Advent.Helpers.Utility, as: U
  use Timing

  @victory_condition %State{x: 31, y: 39}
  #@victory_condition %State{x: 7, y: 4}

  @max_depth 50

  def distance(state) do
    0
  end

  # Returns true if move1 is better than move2
  def heuristic_sort(move1, move2) do
    distance(move1) < distance(move2)
  end

  def flatten_states(e, acc) do
    [Enum.reduce([], e, fn([x], [acc2]) -> [x|acc] end)|acc]
  end

  defp get_openset([], acc), do: acc
  defp get_openset(state, acc), do: get_openset(Cache.pop, [state|acc])

  def search(initial, 0) do
    Cache.open(initial, State.canonicalise(initial))
    search(1)
  end

  def search_tree_cardinality(initial, 0) do
    Cache.open(initial, State.canonicalise(initial))
    search(1, true)
  end

  def search(depth, return_cardinality \\ false) do
    #U.i depth, "searching at depth"
    #IO.gets "boop?"
    #U.i Cache.openset, "current open set"
    #U.i Cache.closed, "current closed set"

    Enum.each(get_openset(Cache.pop, []), fn(open) ->
      Enum.each(State.successors(open), fn(succ) ->
        Cache.open(succ, State.canonicalise(succ))
      end)
    end)

    #U.i length(Cache.openset), "  cardinality of openset"

    #U.i Cache.openset, "current open set"
    #U.i Cache.closed, "current closed set"

    if return_cardinality do
      if depth == @max_depth do
        Enum.count(Cache.closed)
      else
        search(depth+1, true)
      end
    else
      if Enum.any?(Cache.openset, fn(state) ->
        state == @victory_condition
      end) do
        depth
      else
        search(depth+1, return_cardinality)
      end
    end
  end

  def a do
    initial_state = %State{x: 1, y: 1}
    Cache.init(&heuristic_sort/2)

    {elapsed, result} = time do
      search(initial_state, 0)
    end
  end

  def b do
    initial_state = %State{x: 1, y: 1}
    Cache.init(&heuristic_sort/2)

    {elapsed, result} = time do
      search_tree_cardinality(initial_state, 0)
    end
  end

end

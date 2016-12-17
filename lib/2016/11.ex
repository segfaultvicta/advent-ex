defmodule Advent.Sixteen.Eleven.Cache do
  alias Advent.Helpers.Utility, as: U
  alias Advent.Helpers.Eleven.State

  def init(heuristic_function) do
    Agent.start_link(fn ->
      %{openset: [], visited: MapSet.new, sort: heuristic_function}
    end, name: :cache)
  end

  defp _sort_function do
    Agent.get(:cache, fn(%{openset: _, visited: _, sort: sort}) -> sort end)
  end

  def closed do
    Agent.get(:cache, fn(%{openset: _, visited: visited, sort: _}) -> visited end)
  end

  def openset do
    Agent.get(:cache, fn(%{openset: openset, visited: _, sort: _}) -> openset end)
  end

  def closed?(canonical_state) do
    Enum.member?(closed, canonical_state)
  end

  def close(canonical_state) do
    Agent.update(:cache, fn(%{openset: openset, visited: visited, sort: sort}) ->
      %{openset: openset, visited: MapSet.put(visited, canonical_state), sort: sort}
    end)
  end

  def open?(state) do
    Enum.any?(openset, fn(open) -> open.list == state.list and open.floor == state.floor end)
  end

  def open(state, canonical_state) do
    #U.i state, "opening state"
    #U.i canonical_state, "with canonical form"
    if (not closed? canonical_state) and (not open? state) do
      close(canonical_state)
      Agent.update(:cache, fn(%{openset: openset,visited: visited, sort: sort}) ->
        %{openset: [state | openset], visited: visited, sort: sort}
      end)
    end
  end

  def pop do
    open = openset
    if length(open) > 1 do
      [best|rest] = openset
      Agent.update(:cache, fn(%{openset: _, visited: visited, sort: sort}) ->
        %{openset: rest, visited: visited, sort: sort}
      end)
      best
    else
      if length(open) == 1 do
        [last] = openset
        Agent.update(:cache, fn(%{openset: _, visited: visited, sort: sort}) ->
          %{openset: [], visited: visited, sort: sort}
        end)
        last
      else
        []
      end
    end
  end

  def sort do
    sorted = Enum.sort(openset, _sort_function)
    Agent.update(:cache, fn(%{openset: _, visited: visited, sort: sort}) ->
      %{openset: sorted, visited: visited, sort: sort}
    end)
  end
end

defmodule Advent.Sixteen.Eleven.Lookup do
  def init(chips, gens) do
    Agent.start_link(fn ->
      [chips, gens]
    end, name: :lookup)
  end

  def curr do
    Agent.get(:lookup, &(&1))
  end

  def chips do
    curr |> Enum.at(0)
  end

  def gens do
    curr |> Enum.at(1)
  end
end

defmodule Advent.Sixteen.Eleven.State do
  alias Advent.Sixteen.Eleven.Lookup
  alias Advent.Helpers.Utility, as: U
  defstruct [:list, :floor, :history]

  def to_list(state) do
    [state.list, state.floor, state.history]
  end

  defp _with_generator(chip, state) do
    Enum.at(state, chip) == Enum.at(state, chip-1)
  end

  defp _with_another_generator(chip, state) do
    Enum.any?(Lookup.gens, fn(generator) ->
      Enum.at(state, generator) == Enum.at(state, chip)
    end)
  end

  def valid(state) do
    #U.i state, "testing validity of"
    not Enum.any?(Lookup.chips, fn(chip) ->
      not _with_generator(chip, state.list) and _with_another_generator(chip, state.list)
    end)
  end

  def canonicalise(state) do
    #U.i state, "to canonicalise:"
    state.list |> Enum.chunk(2) |> Enum.map(fn([genfloor, chipfloor]) -> state.floor*100 + genfloor*10 + chipfloor end) |> Enum.sort
  end
end

defmodule Advent.Sixteen.Eleven do
  alias Advent.Sixteen.Eleven.Cache
  alias Advent.Sixteen.Eleven.Lookup
  alias Advent.Sixteen.Eleven.State
  alias Advent.Helpers.Utility, as: U

  use Timing

  @max_tree 55
  @max_iter 10000
  @floors 4
  @columns 14
  #@columns 10
  #@columns 4 # 2*number of chip types - each chip & generator gets a column
  @victory_condition [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
  #@victory_condition [4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
  #@victory_condition [4, 4, 4, 4]
  @initial [1, 1, 1, 1, 2, 3, 2, 2, 2, 2, 1, 1, 1, 1]
  #@initial [1, 1, 1, 1, 2, 3, 2, 2, 2, 2]
  #@initial [2, 1, 3, 1]
  @chips [1, 3, 5, 7, 9, 11, 13]
  #@chips [1, 3, 5, 7, 9]
  #@chips [1, 3]
  @gens [0, 2, 4, 6, 8, 10, 12]
  #@gens [0, 2, 4, 6, 8]
  #@gens [0, 2]

  def distance(state) do
    Enum.reduce(@victory_condition, 1, &(&1+&2)) - Enum.reduce(state.list, 1, &(&1+&2))
  end

  # Returns true if move1 is better than move2
  def heuristic_sort(move1, move2) do
    distance(move1) < distance(move2)
  end

  def flatten_states(e, acc) do
    [Enum.reduce([], e, fn([x], [acc2]) -> [x|acc] end)|acc]
  end

  def fan(state) do
    %State{list: list, floor: floor, history: _} = state
    list
    |> Enum.with_index
    |> Enum.filter(fn({at, _}) -> at == floor end)
    |> Enum.map(fn({_, index}) -> index end)
    |> combinations
    |> combinations_to_moves(floor)
    |> moves_to_states(state)
    |> List.flatten
    |> Enum.filter(&State.valid/1)
  end

  defp do_process_row([], acc), do: acc
  defp do_process_row(state, acc) do
    #U.i acc, "acc"
    #U.i state, "popped from cache"
    #Cache.close(State.canonicalise(state))
    do_process_row(Cache.pop, [state|acc])
  end

  def search(initial, 0) do
    Cache.open(initial, State.canonicalise(initial))
    search(1)
  end

  def search(depth) do
    U.i depth, "searching at depth"
    #IO.gets "boop?"
    #U.i Cache.openset, "current open set"
    #U.i Cache.closed, "current closed set"

    Enum.each(do_process_row(Cache.pop, []), fn(open) ->
      Enum.each(fan(open), fn(succ) ->
        Cache.open(succ, State.canonicalise(succ))
      end)
    end)

    U.i length(Cache.openset), "  cardinality of openset"

    #U.i Cache.openset, "current open set"
    #U.i Cache.closed, "current closed set"

    if Enum.any?(Cache.openset, fn(state) -> state.list == @victory_condition end) do
      depth
    else
      search(depth+1)
    end
  end

  def a do
    initial_state = %State{list: @initial, floor: 1, history: [@initial]}
    Lookup.init(@chips, @gens)
    Cache.init(&heuristic_sort/2)

    {elapsed, result} = time do
      search(initial_state, 0)
    end
  end

  def b do
  end

  def combinations(list) when length(list) == 1 do
    [list]
  end
  def combinations(list) when length(list) > 1 do
    Combination.combine(list, 2) ++ Enum.map(list, &([&1]))
  end
  def combinations_to_moves(combinations, floor) do
    Enum.map(combinations, fn(combo) ->
      case floor do
        1 ->
          [%State{list: Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [1] else acc ++ [0] end end), floor: 1}]
        2 ->
          [%State{list: Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [1] else acc ++ [0] end end), floor: 1},
          %State{list: Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [-1] else acc ++ [0] end end), floor: -1}]
        3 ->
          [%State{list: Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [1] else acc ++ [0] end end), floor: 1},
          %State{list: Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [-1] else acc ++ [0] end end), floor: -1}]
        4 ->
          [%State{list: Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [-1] else acc ++ [0] end end), floor: -1}]
        end
    end)
  end

  def moves_to_states(moves, state) do
    Enum.map(moves, fn(move) ->
      #U.i state, "state"
      #U.i move, "move"
      case length(move) do
        1 -> [applymove(state, move)]
        2 ->
          [umove, dmove] = move
          [applymove(state, [umove]),applymove(state, [dmove])]
      end
    end)
  end

  def applymove(state, [move]) do
    #U.i state, "state in applymove"
    #U.i move, "move in applymode"
    %State{list: Enum.zip(state.list, move.list) |> Enum.map(fn({x,y}) -> x + y end), floor: state.floor + move.floor, history: state.history}
  end

end

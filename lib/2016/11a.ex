defmodule Advent.Sixteen.ElevenA.Cache do
  alias Advent.Helpers.Utility, as: U
  alias Advent.Helpers.ElevenA.State

  def init(heuristic_function) do
    Agent.start_link(fn ->
      %{openset: [], visited: MapSet.new, sort: heuristic_function}
    end, name: :cache)
  end

  defp _sort_function do
    Agent.get(:cache, fn(%{openset: openset, visited: visited, sort: sort}) -> sort end)
  end

  def closed do
    Agent.get(:cache, fn(%{openset: openset, visited: visited, sort: sort}) -> visited end)
  end

  def openset do
    Agent.get(:cache, fn(%{openset: openset, visited: visited, sort: sort}) -> openset end)
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
    Enum.member?(openset, state)
  end

  def open(state, canonical_state) do
    if (not closed? canonical_state) and (not open? state.to_list) do
      Agent.update(:cache, fn(%{openset: openset,visited: visited, sort: sort}) ->
        %{openset: [state.to_list | openset], visited: visited, sort: sort}
      end)
    end
  end

  def pop do
    [best|rest] = openset
    Agent.update(:cache, fn(%{openset: openset, visited: visited, sort: sort}) ->
      %{openset: rest, visited: visited, sort: sort}
    end)
    if length(best) >= 1 do best else :nil end
  end

  def sort do
    sorted = Enum.sort(openset, _sort_function)
    Agent.update(:cache, fn(%{openset: openset, visited: visited, sort: sort}) ->
      %{openset: sorted, visited: visited, sort: sort}
    end)
  end
end

defmodule Advent.Sixteen.ElevenA.Lookup do
  def init(all, chips, gens) do
    Agent.start_link(fn ->
      [all, chips, gens]
    end, name: :lookup)
  end

  def curr do
    Agent.get(:lookup, &(&1))
  end

  def chips do
    curr |> Enum.at(1)
  end

  def gens do
    curr |> Enum.at(2)
  end

  def c(index) do
    curr |> Enum.at(0) |> Enum.at(index)
  end
end

defmodule Advent.Sixteen.ElevenA.State do
  alias Advent.Sixteen.ElevenA.Lookup
  defstruct [:list, :floor]

  def to_list(state) do
    [state.list, state.floor]
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
    not Enum.any?(Lookup.chips, fn(chip) ->
      not _with_generator(chip, state.list) and _with_another_generator(chip, state.list)
    end)
  end

  def canonicalise(state) do
    state.list |> Enum.chunk(2) |> Enum.map(fn([genfloor, chipfloor]) -> state.floor*100 + genfloor*10 + chipfloor end) |> Enum.sort
  end
end

defmodule Advent.Sixteen.ElevenA do
  alias Advent.Sixteen.ElevenA.Cache
  alias Advent.Sixteen.ElevenA.Lookup
  alias Advent.Sixteen.ElevenA.State
  alias Advent.Helpers.Utility, as: U

  @max_tree 55
  @max_iter 10000
  @floors 4
  @columns 10
  @columns 4 # 2*number of chip types - each chip & generator gets a column
  @victory_condition [4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
  @victory_condition [4, 4, 4, 4]
  @initial [1, 1, 1, 1, 2, 3, 2, 2, 2, 2]
  @initial [2, 1, 3, 1]
  @chips [1, 3, 5, 7, 9]
  @chips [1, 3]
  @gens [0, 2, 4, 6, 8]
  @gens [0, 2]
  @all [:StG, :StC, :PuG, :PuC, :TmG, :TmC, :RuG, :RuC, :CrG, :CrC]
  @all [:HG, :HC, :LG, :LC]

  def applymove({state, current_floor}, [{move, floor_d}]) do
    {s,f} = {Enum.zip(state, move) |> Enum.map(fn({x,y}) -> x + y end), current_floor + floor_d}
    %State{list: s, floor: f}
  end

  def distance([state, floor, history]) do
    Enum.reduce(@victory_condition, 1, &(&1+&2)) - Enum.reduce(state, 1, &(&1+&2))
  end

  # Returns true if move1 is better than move2
  def heuristic_sort(move1, move2) do
    distance(move1) < distance(move2)
    #:crypto.rand_uniform(0,2) == 1
  end

  def flatten_states(e, acc) do
    acc ++ Enum.reduce([], e, fn([x], acc2) -> acc2 ++ x end)
  end

  def fan({state, floor}) do
    indices = state
    |> Enum.with_index
    |> Enum.filter(fn({at, _}) -> at == floor end)
    |> Enum.map(fn({_, index}) -> index end)
    |> combinations
    |> combinations_to_moves(floor)
    |> moves_to_states({state, floor})
    |> Enum.reduce([],&flatten_states/2)
    |> Enum.map(&State.to_tuple/1)
    |> Enum.filter(&State.valid/1)
  end

  def search([tovisit, floor, history], _) when length(history) >= @max_tree_depth do
    Cache.close([tovisit, floor])
    {:prune, 0, 0, 0}
  end

  def search(_, depth) when depth >= @max_recursion_depth do
    {:fuck, 0, depth, 0}
  end

  def search([@victory_condition, 4, history], depth) do
    {:ok, length(history) - 1, depth, length(Cache.openset)}
  end

  def search([tovisit, floor, history], depth) do
    #U.i {tovisit, floor}, "search:"
    Cache.close([tovisit, floor])
    Enum.each(fan({tovisit, floor}), fn({tovisit, floor}) -> Cache.open([tovisit, floor, history]) end)
    #U.i length(Cache.openset), "openset cardinality"
    Cache.sort
    [tovisit, floor, history] = Cache.pop

    {code, pathlength, depth, openset} = search([tovisit, floor, history ++ [[tovisit,floor]]], depth+1)

    case code do
      :ok ->
        {code, pathlength, depth, openset}
      :fuck ->
        {code, depth, "well, fuck."}
      :prune ->
        [tovisit, floor, history]  = Cache.pop
        search([tovisit, floor, history ++ [[tovisit,floor]]], depth+2)
    end
  end

  def a do
    initial_state = @initial
    Lookup.init(@all, @chips, @gens)
    Cache.init(&heuristic_sort/2)
    {c, l, d, o} = search([initial_state, 1, [[initial_state,1]]], 0)
    U.i c, "status code"
    U.i l, "path length"
    U.i d, "recursion depth required"
    U.i o, "openset cardinality at completion"
    l
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
          [{Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [1] else acc ++ [0] end end), 1}]
        2 ->
          [{Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [1] else acc ++ [0] end end), 1},
          {Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [-1] else acc ++ [0] end end), -1}]
        3 ->
          [{Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [1] else acc ++ [0] end end), 1},
          {Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [-1] else acc ++ [0] end end), -1}]
        4 ->
          [{Enum.reduce(0..@columns-1, [], fn(col, acc) -> if Enum.member?(combo, col) do acc ++ [-1] else acc ++ [0] end end), -1}]
        end
    end)
  end
  def moves_to_states(moves, state) do
    Enum.map(moves, fn(move) ->
      case length(move) do
        1 -> [applymove(state, move)]
        2 ->
          [umove, dmove] = move
          [applymove(state, [umove]),applymove(state, [dmove])]
      end
    end)
  end
end

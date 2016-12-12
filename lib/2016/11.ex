defmodule Advent.Sixteen.Eleven.Cache do
  alias Advent.Helpers.Utility, as: U

  def init do
    if (proc = Process.get(:cache)) != nil do
      Agent.stop(:cache)
    end
    Agent.start_link(fn ->
      []
    end, name: :cache)
  end

  def visited do
    Agent.get(:cache, &(&1))
  end

  def visited?(state) do
    Enum.member?(visited, state)
  end

  def visit(gamestate) do
    Agent.update(:cache, fn(state) -> state ++ [gamestate] end)
  end
end

defmodule Advent.Sixteen.Eleven.Lookup do
  def init(all, chips, gens) do
    if (proc = Process.get(:lookup)) != nil do
      Agent.stop(:lookup)
    end
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

defmodule Advent.Sixteen.Eleven do
  alias Advent.Sixteen.Eleven.Cache
  alias Advent.Sixteen.Eleven.Lookup
  alias Advent.Helpers.Utility, as: U
  @max_recursion_depth 20
  @floors 4
  #@columns 10
  @columns 4 # 2*number of chip types - each chip & generator gets a column
  #@victory_condition [4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
  @victory_condition [4, 4, 4, 4]
  #@initial [1, 1, 1, 1, 2, 3, 2, 2, 2, 2])
  @initial [2, 1, 3, 1]
  #@chips [1, 3, 5, 7, 9]
  @chips [1, 3]
  #@gens [0, 2, 4, 6, 8]
  @gens [0, 2]
  #@all [:StG, :StC, :PuG, :PuC, :TmG, :TmC, :RuG, :RuC, :CrG, :CrC]
  @all [:HG, :HC, :LG, :LC]


  def indices_at_floor(state, floor) do
    Enum.with_index(state)
    |> Enum.filter_map(fn({i,_}) -> i == floor end, fn({_,j}) -> j end)
  end

  def objects_at_floor(state, floor) do
    indices_at_floor(state, floor) |> Enum.map(fn(e) -> {e, Lookup.c(e)} end)
  end

  def matrix(state) do
    for f <- 1..@floors do
      objects_at_floor(state, f)
    end
    |> Enum.map(fn(floor) ->
      acc = []
      for c <- 0..@columns - 1 do
        target = Enum.find(floor, {nil, :___},  fn({col_index, _}) ->
          col_index == c
        end)
        {_, value} = target
        [value] ++ acc
      end
      |> Enum.map(fn([e]) -> e end)
      |> Vector.from_list
    end)
    |> Enum.reverse
    |> Matrix.from_rows
  end
  def with_generator(chip, state), do: state[chip] == state[chip-1]
  def with_another_generator(chip, state), do: Enum.any?(Lookup.gens, fn(generator) -> state[generator] == state[chip] end)
  def valid(state), do: not Enum.any?(Lookup.chips, fn(chip) -> not with_generator(chip, state) and with_another_generator(chip, state) end)
  def movement_vector([e1, e2]) do
    v = Vector.new(@columns)
    v = put_in v[e1], 1
    v = put_in v[e2], 1
  end
  def movement_vector(move) do
    v = Vector.new(@columns)
    put_in v[move], 1
  end
  def move_up(state, potentialmoves, floor) do
    for move <- potentialmoves do
      {:up, floor+1, move, Vector.add(state, movement_vector(move))}
    end
  end
  def move_down(state, potentialmoves, floor) do
    for move <- potentialmoves do
      {:down, floor-1, move, Vector.sub(state, movement_vector(move))}
    end
  end
  def move_both(state, potentialmoves, floor) do
    for move <- potentialmoves do
      [{:up, floor+1, move, Vector.add(state, movement_vector(move))}, {:down, floor-1, move, Vector.sub(state, movement_vector(move))}]
    end
  end

  def rule_out_cached_nodes({_, _, _, move}) do
    if Cache.visited?(move) do false else true end
  end

  def distance({_, _, _, state}) do
    Enum.reduce(@victory_condition, 1, &(&1+&2)) - Enum.reduce(state, 1, &(&1+&2))
  end

  # Returns true if move1 is better than move2
  def heuristic_sort(move1, move2) do
    distance(move1) < distance(move2)
  end

  def fan(state, floor) do
    indices = indices_at_floor(state, floor)
    combos = if length(indices) > 1 do
      Combination.combine(indices, 2) ++ indices
    else
      indices
    end
    #U.i indices, "indices in fan function"
    newmoves = case floor do
      1 ->
        move_up(state, combos, floor)
      4 ->
        move_down(state, combos, floor)
      _ ->
        move_up(state, combos, floor) ++ move_down(state, combos, floor)
    end
  end

  def search({_,_}, _, history) when length(history) >= @max_recursion_depth do
    {:error, :max_recursion_depth}
  end
  def search({@victory_condition,@floors}, _, history) do
    {:ok, history}
  end

  def search({state, floor}, openset, history) do
    #U.i matrix(state), "state"
    #U.i floor, "floor"
    #U.i openset, "openset"
    Cache.visit(state)
    #U.i Cache.visited, "cache"
    # Generate a bunch of possible next steps, make sure none of them lead to a fried state, then try them all
    # General considerations:
    #   Always try to move up whenever possible.
    newmoves = fan(state, floor)
    #|> U.i("all possible moves this step")
    |> Enum.filter(fn({_, _, _, state}) -> valid(state) end)
    #|> U.i("after filtering out the wedged ones")
    |> Enum.filter(&(rule_out_cached_nodes(&1)))
    #|> U.i("available moves generated this step")
    openset = openset ++ newmoves
    |> Enum.sort(&(heuristic_sort(&1, &2)))
    #|> U.i("available moves right now")
    #[{direction, floor, move, movestate}] = Enum.take(openset, 1)
    #U.i openset, "openset:"

    #r = Enum.map(openset, fn({direction, floor, move, movestate}) ->
      #U.i {direction, move}, "doing\n============================================"
    for r <- openset do

    end
    #{status, details} = search({movestate, floor}, List.delete(openset, {direction, floor, move, movestate}), history ++ [state])
    #end)
    |> Enum.find(fn({status, details}) -> status == :ok end)
    #if r != nil do
    #  {_, details} = r
    #  {:ok, details}
    #else
    #  {:error, :max_recursion_depth}
    #end
    #|> Enum.map(fn(task) -> Task.await(task, 20000) end)
    #|> Enum.reduce(@max_recursion_depth, fn({status, depth}, bestDepth) ->
    #IO.puts "handling input"
    #if status == :ok do
    # {:ok}
    #else
    #  {:error, :max_recursion_depth}
    #end
  end

  def a do
    initial_state = Vector.from_list(@initial)
    Lookup.init(@all, @chips, @gens)
    Cache.init

    #Task.await(Task.async(fn -> search(initial_state, 0, 1) end), 20000)
    search({initial_state, 1}, [], [])
  end

  def b do
  end

end

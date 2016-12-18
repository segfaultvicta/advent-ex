defmodule Advent.Sixteen.Seventeen.State do
  alias Advent.Helpers.Utility, as: U
  alias Advent.Sixteen.Seventeen.State

  defstruct [:x, :y, :laststep, :hashcontext]

  @opendoor ["B", "C", "D", "E", "F"]

  def to_list(state) do
    [state.x, state.y, state.laststep, state.hashcontext]
  end

  def valid(state, stateList) do
    #doors = :crypto.hash(:md5 , @input <> state.path) |> Base.encode16()
    #U.i state, "checking validity of"
    newcontext = :crypto.hash_update(state.hashcontext, state.laststep)
    :crypto.hash_final(newcontext) |> Base.encode16()
    |> String.codepoints |> Enum.take(4)
    |> Enum.zip(stateList)
    |> Enum.filter(fn({key, teststate}) ->
      x = teststate.x
      y = teststate.y
      if x < 0 or x > 3 or y < 0 or y > 3 do false else
        Enum.member?(@opendoor, key)
      end
    end)
    |> Enum.map(fn({key, teststate}) -> teststate end)
    |> Enum.map(fn(teststate) -> %{teststate | hashcontext: newcontext} end)
  end

  def successors(state) do
    nesw = [%State{x: state.x - 1, y: state.y, laststep: "U", hashcontext: state.hashcontext},
            %State{x: state.x + 1, y: state.y, laststep: "D", hashcontext: state.hashcontext},
            %State{x: state.x, y: state.y - 1, laststep: "L", hashcontext: state.hashcontext},
            %State{x: state.x, y: state.y + 1, laststep: "R", hashcontext: state.hashcontext},]
    valid(state, nesw)
  end

  def canonicalise(state) do
    to_list(state)
  end
end

defmodule Advent.Sixteen.Seventeen do
  alias Advent.Helpers.NodeCache, as: Cache
  alias Advent.Sixteen.Seventeen.State
  alias Advent.Helpers.Utility, as: U
  use Timing

  @input "awrkjxxr"
  #@input "ihgpwlah"

  defp get_openset([], acc), do: acc
  defp get_openset(state, acc), do: get_openset(Cache.pop, [state|acc])

  def search(initial, 0, b_side) do
    Cache.open(initial)
    if b_side do do_search_b(1) else do_search_a(1) end
  end

  def do_search_a(depth) do
    # lol I don't have my working A solution anymore, sorry
  end

  def do_search_b(depth) do
    potential_wins = Enum.map(get_openset(Cache.pop, []), fn(open) ->
      Enum.map(State.successors(open), fn(succ) ->
        if ((succ.x == 3) and (succ.y == 3)) do
          succ
        else
          Cache.open(succ)
          :nil
        end
      end)
      |> Enum.filter(fn(succ) -> succ != :nil end)
    end) |> Enum.filter(fn(open) -> open != [] end)

    if length(potential_wins) > 0 do
      IO.puts "new candidate path, length #{depth}"
      IO.puts "open set cardinality is #{length(Cache.openset)}"
    end

    cond do
      length(Cache.openset) == 0 -> "aaaand we're done here"
      true -> do_search_b(depth+1)
    end
  end

  def a do
  end

  def b do
    initial_state = %State{x: 0, y: 0, hashcontext: :crypto.hash_init(:md5), laststep: @input}
    Cache.init()

    {elapsed, result} = time do
      search(initial_state, 0, true)
    end
  end

end

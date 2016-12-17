defmodule Advent.Helpers.NodeCache do
  alias Advent.Helpers.Utility, as: U

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
    Enum.member?(openset, state)
  end

  def open(state, canonical_state) do
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

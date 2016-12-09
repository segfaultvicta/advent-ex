defmodule Advent.Helpers.Map do

  def from_list(list) when is_list(list) do
    _from_list(list)
  end

  defp _from_list(list, map \\ %{}, index \\ 0)
  defp _from_list([], map, _index), do: map
  defp _from_list([h|t], map, index) do
    map = Map.put(map, index, _from_list(h))
    _from_list(t, map, index + 1)
  end
  defp _from_list(other, _, _), do: other
end

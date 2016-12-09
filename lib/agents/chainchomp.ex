defmodule Advent.Agents.Chainchomp do

  def init(binary, name) do
    start binary, name
  end

  defp start(binary, name) do
    Agent.start_link(fn ->
      %{string: binary, stringposition: 0}
    end, name: name)
  end

  def kill(name) do
    Agent.stop(name)
  end

  def curr(name) do
    Agent.get(name, fn(state) -> state end)
  end

  def string(name) do
    curr(name).string
  end

  def peek(name) do
    String.slice(rest(name), 0, 1)
  end

  def rest(name) do
    elem(String.split_at(string(name), pos(name)), 1)
  end

  def contains?(name, needle) do
    String.contains?(curr(name).string, needle)
  end

  def rest_contains?(name, needle) do
    String.contains?(rest(name), needle)
  end

  def pos(name) do
    curr(name).stringposition
  end

  def setpos(name, pos) do
    Agent.update(name,
    fn(state) ->
      %{string: state.string, stringposition: pos}
    end)
  end

  def take_number(name) do
    {number, remainder} = rest(name) |> Integer.parse
    numStringLength = String.length(rest(name)) - String.length(remainder)
    setpos(name, pos(name) + numStringLength)
    number
  end

  def take_chara(name), do: take_next(name, 1)

  def take_next(name, length) do
    binary = rest(name) |> String.split_at(length)
    setpos(name, pos(name) + length)
    elem(binary, 0)
  end
end

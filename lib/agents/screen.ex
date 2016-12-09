defmodule Advent.Agents.Screen do

  def init(width, height) do
    __MODULE__.start width, height
  end

  def start(width, height) do
    Agent.start_link(fn ->
      Matrix.new [], height, width, " "
    end, name: __MODULE__)
  end

  def curr do
    Agent.get(__MODULE__, fn(state) -> state end)
  end

  def set(x, y, value) do
    Agent.update(__MODULE__,
    fn matrix ->
      put_in matrix[y][x], value
    end)
  end

  def copy do
    Matrix.from_rows(curr |> Matrix.to_list)
  end

  def at(matrix, x, y) do
    matrix[y][x]
  end

  def at(x, y) do
    curr[y][x]
  end

end

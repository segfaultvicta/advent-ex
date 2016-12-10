defmodule Advent.Agents.Bot do
  def init(["bot", name, "gives", "low", "to", "bot", low, "and", "high", "to", "bot", high]) do
    #IO.puts "bot #{name}: low -> [#{low}] high -> [#{high}]"
    Agent.start_link(fn ->
      %{low: %{type: :bot, target: String.to_atom(low)}, high: %{type: :bot, target: String.to_atom(high)}, carrying: []}
    end, name: String.to_atom(name))
  end

  def init(["bot", name, "gives", "low", "to", "output", low, "and", "high", "to", "bot", high]) do
    #IO.puts "bot #{name}: low -> <<<#{low}>>> high -> [#{high}]"
    Agent.start_link(fn ->
      %{low: %{type: :output, target: String.to_atom(low)}, high: %{type: :bot, target: String.to_atom(high)}, carrying: []}
    end, name: String.to_atom(name))
  end

  def init(["bot", name, "gives", "low", "to", "bot", low, "and", "high", "to", "output", high]) do
    #IO.puts "bot #{name}: low -> [#{low}] high -> <<<#{high}>>>"
    Agent.start_link(fn ->
      %{low: %{type: :bot, target: String.to_atom(low)}, high: %{type: :output, target: String.to_atom(high)}, carrying: []}
    end, name: String.to_atom(name))
  end

  def init(["bot", name, "gives", "low", "to", "output", low, "and", "high", "to", "output", high]) do
    #IO.puts "bot #{name}: low -> <<<#{low}>>> high -> <<<#{high}>>>"
    Agent.start_link(fn ->
      %{low: %{type: :output, target: String.to_atom(low)}, high: %{type: :output, target: String.to_atom(high)}, carrying: []}
    end, name: String.to_atom(name))
  end

  # %{low: %{type: :bot, target: String.to_atom(low)}, high: %{type: :bot, target: String.to_atom(high)}, carrying: []}
  def _update(%{low: %{type: lowtype, target: low}, high: %{type: hightype, target: high}, carrying: []}, value) do
    #IO.puts "  storing #{value}"
    {:ok, %{low: %{type: lowtype, target: low}, high: %{type: hightype, target: high}, carrying: [value]}}
  end

  def _update(%{low: %{type: _, target: _}, high: %{type: _, target: _}, carrying: [_]}, _) do
    #IO.puts "  cascade!!!"
    {:cascade}
  end

  def _cascade(%{low: %{type: lowtype, target: lowtarget}, high: %{type: hightype, target: hightarget}, carrying: [value1]}, value2) do
    #IO.puts "  cascade: #{value1} and #{value2}"
    [low, high] = Enum.sort([value1, value2])
    #IO.puts "    low val #{low} -> #{lowtype} #{lowtarget}"
    #IO.puts "    high val #{high} -> #{hightype} #{hightarget}"
    push(lowtarget, lowtype, low)
    push(hightarget, hightype, high)
    %{low: %{type: lowtype, target: lowtarget}, high: %{type: hightype, target: hightarget}, carrying: []}
  end

  def push(name, :output, value) do
    IO.puts "!!!!!!!!!!!                               OUTPUT #{name} RECIEVING VALUE #{value}"
  end

  def push(name, :bot, value) do
    #IO.puts "#{name} <-- #{value}:"
    Agent.update(name, fn(state) ->
      case _update(state, value) do
        {:ok, state} -> state
        {:cascade} -> _cascade(state, value)
      end
    end)
  end
end

defmodule Advent.Sixteen.Ten do
  alias Advent.Agents.Bot
  @input "./input/2016/10"

  def handlevalue(["value", val, "goes", "to", "bot", bot]) do
    String.to_atom(bot)
    |> Bot.push(:bot, String.to_integer(val))
  end

  def a do
    input = File.read!(@input)
    |> String.split("\n")
    |> Enum.map(&(String.split(&1)))
    input
    |> Enum.filter(&(List.first(&1) == "bot"))
    |> Enum.each(fn(list) ->
      Bot.init(list)
    end)
    input
    |> Enum.filter(&(List.first(&1) == "value"))
    |> Enum.each(&handlevalue/1)
  end

  def b do
    File.read!(@input)
  end
end

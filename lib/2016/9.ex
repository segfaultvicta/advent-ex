defmodule Advent.Sixteen.Nine.Tokeniser do
  alias Advent.Agents.Chainchomp

  def init(string, proc) do
    Chainchomp.init(string, proc)
  end

  def string(proc) do
    Chainchomp.string(proc)
  end

  def remaining(proc) do
    String.length(Chainchomp.rest(proc))
  end

  defp _unpack(proc) do
    Chainchomp.take_chara(proc)
    size = Chainchomp.take_number(proc)
    Chainchomp.take_chara(proc)
    times = Chainchomp.take_number(proc)
    Chainchomp.take_chara(proc)
    Chainchomp.take_next(proc, size)
    |> String.duplicate(times)
  end

  def take(proc) do
    case Chainchomp.peek(proc) do
      "(" -> _unpack(proc)
      _ -> Chainchomp.take_chara(proc)
    end
  end
end

defmodule Advent.Sixteen.Nine do
  alias Advent.Sixteen.Nine.Tokeniser
  alias Advent.Agents.Chainchomp
  @input "./input/2016/9"

  def slurp(acc, 0), do: acc
  def slurp(acc, _), do: slurp(acc <> Tokeniser.take(:base), Tokeniser.remaining(:base))

  def zipbomb(bin), do: _zipbomb(bin, 0)

  defp _zipbomb([], acc), do: acc
  defp _zipbomb([ "(" | rest ], acc) do
    Chainchomp.init(to_string(rest), :zipbomber)
    {count, times, to_duplicate, remaining_string} = _chunk(:zipbomber)
    Chainchomp.kill(:zipbomber)
    if String.contains? to_duplicate, "(" do
      zipbomb(String.codepoints(remaining_string)) + zipbomb(String.codepoints(to_duplicate)) * times + acc
    else
      zipbomb(String.codepoints(remaining_string)) + count * times + acc
    end
  end
  defp _zipbomb([ _ | rest], acc), do: _zipbomb rest, 1 + acc

  defp _chunk(pid) do
    size = Chainchomp.take_number(pid)
    Chainchomp.take_chara(pid) # extraneous 'x'
    times = Chainchomp.take_number(pid)
    Chainchomp.take_chara(pid) # end parenthesis
    {size, times, Chainchomp.take_next(pid, size), Chainchomp.rest(pid)}
  end

  def a do
    File.read!(@input)
    |> String.strip
    |> Tokeniser.init(:base)
    slurp("", Tokeniser.remaining(:base))
    |> String.length
  end

  def b do
    File.read!(@input)
    |> String.strip
    |> String.codepoints
    |> zipbomb
  end

end

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

  def zipbomb("", acc), do: acc
  def zipbomb(string, acc) do
    process_name = :lolwat
    Chainchomp.init(string, process_name)
    if Chainchomp.peek(process_name) == "(" do
      Chainchomp.take_chara(process_name)
      size = Chainchomp.take_number(process_name)
      Chainchomp.take_chara(process_name)
      times = Chainchomp.take_number(process_name)
      Chainchomp.take_chara(process_name)
      to_duplicate = Chainchomp.take_next(process_name, size)
      |> String.duplicate(times)
      rest = Chainchomp.rest(process_name)
      Chainchomp.kill(process_name)
      zipbomb to_duplicate <> rest, acc
    else
      Chainchomp.take_chara(process_name)
      rest = Chainchomp.rest(process_name)
      Chainchomp.kill(process_name)
      zipbomb rest, 1 + acc
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

  def _zipbomb([], acc), do: acc
  def _zipbomb([ "(" | rest ], acc) do
    Chainchomp.init(to_string(rest), :zipbomber)
    {count, times, to_duplicate, remaining_string} = _chunk(:zipbomber)
    Chainchomp.kill(:zipbomber)
    IO.puts "(#{acc}) in zipbomb, duplicating #{to_duplicate} (size #{count}) #{times} times. remaining string: #{remaining_string}"
    if String.contains? to_duplicate, "(" do
      zipbomb(String.codepoints(remaining_string)) + zipbomb(String.codepoints(to_duplicate)) * times + acc
    else
      zipbomb(String.codepoints(remaining_string)) + count * times + acc
    end
  end
  def _zipbomb([ _ | rest], acc), do: _zipbomb rest, 1 + acc

  defp _chunk(pid) do
    size = Chainchomp.take_number(pid)
    Chainchomp.take_chara(pid) # extraneous 'x'
    times = Chainchomp.take_number(pid)
    Chainchomp.take_chara(pid) # end parenthesis
    {size, times, Chainchomp.take_next(pid, size), Chainchomp.rest(pid)}
  end

  def a do
    File.read!(@input)
    #"ADVENT(2x2)AA(4x1)BBBB(8x2)(3x3)ABCY" # "ADVENTAAAABBBB(3x3)ABC(3x3)ABCY"
    |> String.strip
    |> Tokeniser.init(:base)
    slurp("", Tokeniser.remaining(:base))
    |> String.length
  end

  #firsttest = "(3x3)XYZ" # 9
  #secondtest = "X(8x2)(3x3)ABCY" # 20
  #degenerate = "(27x12)(20x12)(13x14)(7x10)(1x12)A" # 241920
  #offbyone = "(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN" # 445
  def b do
    File.read!(@input)
    |> String.strip
    |> String.codepoints
    |> zipbomb
    #|> (Tokeniser.zipbomb 0)
  end

end

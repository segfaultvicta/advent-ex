defmodule Advent.Sixteen.Nine.Tokeniser do
  alias Advent.Agents.Chainchomp
  alias Advent.Helpers.Atom

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
    to_duplicate = Chainchomp.take_next(proc, size)
    |> String.duplicate(times)
  end

  def take(proc) do
    case Chainchomp.peek(proc) do
      "(" -> _unpack(proc)
      x -> Chainchomp.take_chara(proc)
    end
  end

  def zipbomb("", acc), do: acc
  def zipbomb(string, acc) do
    process_name = Atom.random_atom_name
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
  @input "./input/2016/9"

  def slurp(acc, 0), do: acc
  def slurp(acc, n), do: slurp(acc <> Tokeniser.take(:base), Tokeniser.remaining(:base))

  def a do
    File.read!(@input)
    #"ADVENT(2x2)AA(4x1)BBBB(8x2)(3x3)ABCY" # "ADVENTAAAABBBB(3x3)ABC(3x3)ABCY"
    |> String.strip
    |> Tokeniser.init(:base)
    slurp("", Tokeniser.remaining(:base))
    |> String.length
  end

  def b do
    File.read!(@input)
    #"ADVENT(2x2)AA(4x1)BBBB(8x2)(3x3)ABCY" # 33
    |> String.strip
    |> (Tokeniser.zipbomb 0)
  end

end

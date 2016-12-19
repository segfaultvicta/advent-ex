defmodule Advent.Sixteen.Nineteen do
  alias Advent.Helpers.Utility, as: U
  use Timing

  @input 101
  #@input 5

  def greedy_elf(party) do
    Enum.any?(party, fn(x) -> x == @input end)
  end

  def find_greedy_elf(party) do
    Enum.find_index(party, fn(x) -> x == @input end) + 1
  end

  def partytime(party, chair, setnext) do
    U.i party, "PARTY TIIIIME"
    IO.puts "on chair #{chair} and setnext is #{setnext}"
    if greedy_elf(party) do find_greedy_elf(party) else
      IO.puts "a"
      if party[chair] == 0 do partytime(party, chair + 1, -1) else
        IO.puts "b"
        if setnext != -1 do
          IO.puts "c"
          if party[setnext] == 0 do
            setnext = if setnext == @input - 1 do 0 else setnext + 1 end
            partytime(party, chair, setnext)
          else
            IO.puts "d - setnext is #{setnext}"
            party = put_in party[chair], (party[chair] + party[setnext])
            party = put_in party[setnext], 0
            partytime(party, setnext, -1)
          end
        else
          IO.puts "e - chair is #{chair}"
          next = if chair == @input - 1 do 0 else chair + 1 end
          IO.puts "f - next is #{next}"
          if party[next] == 0 do
            setnext = if chair == @input - 1 do 0 else chair + 1 end
            partytime(party, chair, setnext)
          else
            IO.puts "g"
            U.i party[chair], "party[chair]"
            U.i party[next], "party[next]"
            party = put_in party[chair], (party[chair] + party[next])
            party = put_in party[next], 0
            U.i party, "at this point party is"
            partytime(party, next, -1)
          end
        end
      end
    end
  end

  def a do
    {elapsed, result} = time do
      party = Vector.new(@input, 1)
      partytime(party, 0, -1)
    end
  end

  def b do
    {elapsed, result} = time do
    end
  end

end

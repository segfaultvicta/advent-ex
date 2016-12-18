

defmodule Advent.Sixteen.Fourteen do
  alias Advent.Helpers.Utility, as: U
  use Timing
  import DefMemo

  @input "yjdafjpo"
  #@input "abc"

  defmemo stretched_md5(index) do
    #IO.puts index
    stretch(:crypto.hash(:md5, @input <> Integer.to_string(index)) |> Base.encode16(case: :lower), 2016) |> to_charlist
  end

  defmemo md5(index) do
    :crypto.hash(:md5, @input <> Integer.to_string(index)) |> Base.encode16(case: :lower) |> to_charlist
  end

  def stretch(hash, 0), do: hash
  def stretch(hash,times) do
    times = times - 1
    :crypto.hash(:md5, hash) |> Base.encode16(case: :lower) |> stretch(times)
  end

  defmemo triple(hash) do
    r = Enum.map(0..length(hash), fn(x) ->
      if Enum.at(hash, x) == Enum.at(hash, x+1) and
        Enum.at(hash, x) == Enum.at(hash, x+2) do
          Enum.at(hash, x)
        else false
      end
    end)
    |> Enum.filter(fn(x) -> x end)
    |> Enum.take(1)
    if r != [] do r else false end
  end

  defmemo run(index, hash, triple) do
    run = String.duplicate(to_string(triple), 5)
    Enum.any?((index+1)..(index+1000), fn(i) ->
      String.contains?(to_string(md5(i)), run)
    end)
  end

  defmemo stretch_run(index, hash, triple) do
    run = String.duplicate(to_string(triple), 5)
    Enum.any?((index+1)..(index+1000), fn(i) ->
      String.contains?(to_string(stretched_md5(i)), run)
    end)
  end

  def stream_md5 do
    Stream.iterate(0, &(&1+1))
    |> Stream.map(fn(x) -> {x, md5(x)} end)
    |> Stream.map(fn({idx, hash}) -> {idx, hash, triple(hash)} end)
    |> Stream.filter(fn({idx, hash, triple}) -> triple end)
    |> Stream.filter(fn({idx, hash, triple}) -> run(idx, hash, triple) end)
  end

  def stream_stretched_md5 do
    Stream.iterate(0, &(&1+1))
    |> Stream.map(fn(x) -> {x, stretched_md5(x)} end)
    |> Stream.map(fn({idx, hash}) -> {idx, hash, triple(hash)} end)
    |> Stream.filter(fn({idx, hash, triple}) -> triple end)
    |> Stream.filter(fn({idx, hash, triple}) -> stretch_run(idx, hash, triple) end)
  end

  def a do
    {elapsed, result} = time do
      stream_md5 |> Stream.drop(63) |> Enum.take(1)
    end
  end

  def b do
    {elapsed, result} = time do
      stream_stretched_md5 |> Stream.drop(63) |> Enum.take(1)
    end
  end

end

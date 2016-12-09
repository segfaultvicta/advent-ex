defmodule Advent.Helpers.Atom do
  def random_atom_name(length \\ 32) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
    |> String.replace(~r/[\-0-9]/, "_") |> String.to_atom
  end
end

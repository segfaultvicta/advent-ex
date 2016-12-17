defmodule Advent.Sixteen.Register do
  alias Advent.Helpers.Utility, as: U
  def init(name) do
    Agent.start_link(fn ->
      0
    end, name: name)
  end

  def get(name) do
    Agent.get(name, &(&1))
  end

  def cpy(srcname, targname) when is_integer(srcname) do
    Agent.update(targname, fn(_) -> srcname end)
    1
  end

  def cpy(srcname, targname) do
    Agent.update(targname, fn(_) -> get(srcname) end)
    1
  end

  def inc(name, _) do
    Agent.update(name, fn(state) -> state + 1 end)
    1
  end

  def dec(name, _) do
    Agent.update(name, fn(state) -> state - 1 end)
    1
  end

  def add(target, src) do
    Agent.update(target, fn(i) -> get(src) + i end)
    1
  end

  def jnz(name, jump) when is_integer(name) do
    jump
  end

  def jnz(name, jump) do
    if get(name) != 0 do jump else 1 end
  end

  def print_all do
    IO.puts "REGISTER A:#{get(:a)} B:#{get(:b)} C:#{get(:c)} D:#{get(:d)}"
  end
end

defmodule Advent.Sixteen.Twelve do
  alias Advent.Sixteen.Register
  alias Advent.Helpers.Utility, as: U

  def run(mp, program) when mp >= length(program) do
    Register.print_all
  end

  def run(mp, program) do
    {fun, a, b} = Enum.at(program, mp)
    #U.i {fun, a, b}, "instruction: "
    jump = apply(fun, [a, b])
    #Register.print_all
    run(mp + jump, program)
  end

  def a do
    program = [
      {&Register.cpy/2,  1, :a},
      {&Register.cpy/2,  1, :b},
      {&Register.cpy/2,  1, :c},
      {&Register.cpy/2, 26, :d},
      {&Register.jnz/2, :c,  2},
      {&Register.jnz/2,  1,  4},      # GOTO: BETA
      #{&Register.jnz/2,  1,  5},      # GOTO: BETA
      {&Register.cpy/2,  7, :c},      # LABEL: ALPHA
      #{&Register.inc/2,  :d, :nil},
      #{&Register.dec/2,  :c, :nil},
      #{&Register.jnz/2,  :c, -2},
      {&Register.add/2,  :d, :c},
      {&Register.cpy/2,   0, :c},
      {&Register.cpy/2,  :a, :c},     # LABEL: BETA
      #{&Register.inc/2,  :a, :nil},
      #{&Register.dec/2,  :b, :nil},
      #{&Register.jnz/2,  :b, -2},
      {&Register.add/2,  :a, :b},
      {&Register.cpy/2,   0, :b},
      {&Register.cpy/2,  :c, :b},
      {&Register.dec/2,  :d, :nil},
      #{&Register.jnz/2,  :d, -6},      # GOTO: BETA
      {&Register.jnz/2,  :d, -5},      # GOTO: BETA
      {&Register.cpy/2,  17, :c},
      {&Register.cpy/2,  18, :d},      # LABEL: GAMMA
      #{&Register.inc/2,  :a, :nil},
      #{&Register.dec/2,  :d, :nil},
      #{&Register.jnz/2,  :d, -2},
      {&Register.add/2,  :a, :d},
      {&Register.cpy/2,   0, :d},
      {&Register.dec/2,  :c, :nil},
      {&Register.jnz/2,  :c, -4}       # GOTO: GAMMA
    ]

    Register.init(:a)
    Register.init(:b)
    Register.init(:c)
    Register.init(:d)

    mp = 0

    run(mp, program)
  end

  def b do
  end

end

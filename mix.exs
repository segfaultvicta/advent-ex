defmodule Advent.Mixfile do
  use Mix.Project

  def project do
    [app: :advent,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :defmemo]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 0.5"},
      {:tensor, "~> 0.7.0"},
      {:combination, "~> 0.0.2"},
      {:defmemo, "~> 0.1.1"},
      {:timing, git: "git://github.com/Primordus/Timing.git"}
    ]
  end
end

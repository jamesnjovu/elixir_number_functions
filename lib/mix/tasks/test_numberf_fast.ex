defmodule Mix.Tasks.Test.NumberfFast do
  @moduledoc """
  Mix task to run only fast NumberF tests
  """
  use Mix.Task

  @shortdoc "Run fast NumberF tests (excluding performance and benchmark tests)"

  def run(args) do
    Mix.Task.run("compile")

    default_args = [
      "--exclude",
      "performance",
      "--exclude",
      "benchmark",
      "--exclude",
      "property",
      "--exclude",
      "compatibility"
    ]

    all_args = default_args ++ args

    IO.puts("Running fast NumberF tests...")
    Mix.Task.run("test", all_args)
  end
end

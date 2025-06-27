defmodule Mix.Tasks.Test.NumberfAll do
  @moduledoc """
  Mix task to run all NumberF tests with comprehensive coverage
  """
  use Mix.Task

  @shortdoc "Run all NumberF tests including performance and benchmark tests"

  def run(args) do
    # Compile the project first
    Mix.Task.run("compile")

    # Default arguments
    default_args = [
      "--cover",
      "--trace",
      "--slowest",
      "10"
    ]

    # Combine with provided arguments
    all_args = default_args ++ args

    IO.puts("Running comprehensive NumberF test suite...")
    IO.puts("Arguments: #{Enum.join(all_args, " ")}")

    # Run all tests including tagged ones
    Mix.Task.run(
      "test",
      all_args ++
        [
          "--include",
          "performance",
          "--include",
          "property",
          "--include",
          "benchmark",
          "--include",
          "compatibility"
        ]
    )
  end
end

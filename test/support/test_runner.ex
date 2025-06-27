defmodule TestRunner do
  @moduledoc """
  Test runner utilities for NumberF test suite
  """

  @doc """
  Runs all tests with different configurations
  """
  def run_all_tests do
    IO.puts("=== Running NumberF Test Suite ===\n")

    # Run basic tests
    IO.puts("1. Running basic functionality tests...")
    run_tests([])

    # Run performance tests
    IO.puts("\n2. Running performance tests...")
    run_tests(["--include", "performance"])

    # Run property-based tests
    IO.puts("\n3. Running property-based tests...")
    run_tests(["--include", "property"])

    # Run benchmark tests
    IO.puts("\n4. Running benchmark tests...")
    run_tests(["--include", "benchmark"])

    # Run compatibility tests
    IO.puts("\n5. Running compatibility tests...")
    run_tests(["--include", "compatibility"])

    IO.puts("\n=== Test Suite Complete ===")
  end

  @doc """
  Runs tests with coverage analysis
  """
  def run_with_coverage do
    System.cmd("mix", ["test", "--cover"])
  end

  @doc """
  Runs only failed tests
  """
  def run_failed do
    System.cmd("mix", ["test", "--failed"])
  end

  @doc """
  Runs tests for a specific module
  """
  def run_module(module_name) do
    test_file = "test/#{module_name}_test.exs"
    System.cmd("mix", ["test", test_file])
  end

  defp run_tests(args) do
    {output, exit_code} = System.cmd("mix", ["test" | args], stderr_to_stdout: true)

    if exit_code == 0 do
      IO.puts("✅ Tests passed")
    else
      IO.puts("❌ Tests failed")
      IO.puts(output)
    end
  end
end

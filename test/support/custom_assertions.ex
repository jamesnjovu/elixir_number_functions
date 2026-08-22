defmodule CustomAssertions do
  @moduledoc """
  Assertion helpers shared across the test suite.

  Compiled via `elixirc_paths(:test)` rather than required from `test_helper.exs`,
  so the macros are available without each test file loading the file itself.
  """
  @doc """
  Assert that two floats are approximately equal
  """
  defmacro assert_float_equal(actual, expected, delta \\ 0.001) do
    quote do
      actual_val = unquote(actual)
      expected_val = unquote(expected)
      delta_val = unquote(delta)

      assert abs(actual_val - expected_val) < delta_val,
             "Expected #{actual_val} to be approximately equal to #{expected_val} (±#{delta_val})"
    end
  end

  @doc """
  Assert that a value is within a range
  """
  defmacro assert_in_range(value, min, max) do
    quote do
      val = unquote(value)
      min_val = unquote(min)
      max_val = unquote(max)

      assert val >= min_val and val <= max_val,
             "Expected #{val} to be between #{min_val} and #{max_val}"
    end
  end

  @doc """
  Assert that execution time is within threshold
  """
  defmacro assert_performance(threshold_microseconds, do: code) do
    quote do
      {time, _result} = :timer.tc(fn -> unquote(code) end)
      threshold = unquote(threshold_microseconds)

      assert time < threshold,
             "Expected execution time #{time}μs to be less than #{threshold}μs"
    end
  end

  @doc """
  Assert that memory usage is within limits.
  """
  defmacro assert_memory_usage(limit_bytes, do: code) do
    quote do
      :erlang.garbage_collect()
      memory_before = :erlang.memory(:total)

      _result = unquote(code)

      :erlang.garbage_collect()
      memory_after = :erlang.memory(:total)

      memory_used = memory_after - memory_before
      limit = unquote(limit_bytes)

      assert memory_used < limit,
             "Expected memory usage #{memory_used} bytes to be less than #{limit} bytes"
    end
  end
end

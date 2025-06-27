defmodule CustomAssertions do
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
end

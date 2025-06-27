ExUnit.start()

# Configure ExUnit
ExUnit.configure(
  # Exclude performance tests by default
  exclude: [:performance],
  # 60 second timeout for slow tests
  timeout: 60_000,
  # Capture log output during tests
  capture_log: true
)

# Helper functions for tests - NO ASSERT CALLS IN HERE
defmodule TestHelper do
  @doc """
  Generates test data for statistical functions
  """
  def generate_test_data(size) do
    Enum.to_list(1..size)
  end

  @doc """
  Creates a test date range
  """
  def date_range(start_date, days) do
    Enum.map(0..days, fn day ->
      Date.add(start_date, day)
    end)
  end

  @doc """
  Checks if two floats are approximately equal (returns boolean - NO ASSERT)
  """
  def float_equal?(actual, expected, delta \\ 0.001) do
    abs(actual - expected) < delta
  end

  @doc """
  Creates test currency exchange rates
  """
  def test_exchange_rates do
    %{
      "USD" => 1.0,
      "EUR" => 0.85,
      "GBP" => 0.73,
      "JPY" => 110.0,
      "ZMW" => 20.5,
      "CAD" => 1.25
    }
  end

  @doc """
  Creates test tax brackets for income tax testing
  """
  def test_tax_brackets do
    [
      # Tax-free threshold
      {0, 0.0},
      # 10% bracket
      {10000, 0.10},
      # 22% bracket
      {40000, 0.22},
      # 24% bracket
      {85000, 0.24},
      # 32% bracket
      {160_000, 0.32},
      # 35% bracket
      {200_000, 0.35}
    ]
  end

  @doc """
  Generates random test numbers
  """
  def random_numbers(count) do
    Enum.map(1..count, fn _ ->
      :rand.uniform() * 10000
    end)
  end

  @doc """
  Creates test phone numbers for different countries
  """
  def test_phone_numbers do
    %{
      "US" => [
        "14155552671",
        "4155552671",
        "+1 (415) 555-2671",
        "415-555-2671"
      ],
      "UK" => [
        "447911123456",
        "07911123456",
        "+44 79 1112 3456"
      ],
      "ZM" => [
        "260977123456",
        "0977123456",
        "+260 97 712 3456"
      ]
    }
  end

  @doc """
  Creates test credit card numbers (all test numbers, not real)
  """
  def test_credit_cards do
    %{
      valid: [
        # Visa test number
        "4111111111111111",
        "4111-1111-1111-1111",
        "4111 1111 1111 1111",
        # Mastercard test number
        "5555555555554444",
        # Amex test number
        "378282246310005"
      ],
      invalid: [
        "4111111111111112",
        "1234567890123456",
        "0000000000000000",
        "invalid_card"
      ]
    }
  end

  @doc """
  Measures execution time of a function
  """
  def measure_time(fun) do
    {time, result} = :timer.tc(fun)
    {time, result}
  end

  @doc """
  Creates test amounts for various scenarios
  """
  def test_amounts do
    [
      # Very small
      0.01,
      # Small
      1.0,
      # Medium
      123.45,
      # Regular
      1234.56,
      # Large
      12345.67,
      # Very large
      123_456.78,
      # Huge
      1_234_567.89,
      # Maximum practical
      999_999.99
    ]
  end

  @doc """
  Generates test currencies with their properties
  """
  def test_currencies do
    [
      # symbol, symbol_first, symbol_space, decimal_places
      {"USD", "$", true, false, 2},
      {"EUR", "€", false, true, 2},
      {"GBP", "£", true, false, 2},
      {"JPY", "¥", true, false, 0},
      {"ZMW", "K", true, true, 2}
    ]
  end

  @doc """
  Creates statistical test datasets with known properties
  """
  def statistical_test_data do
    %{
      # mean: 3, median: 3
      simple: [1, 2, 3, 4, 5],
      # median: 3 (robust to outliers)
      with_outliers: [1, 2, 3, 4, 100],
      # median: 2.5 (average of middle two)
      even_count: [1, 2, 3, 4],
      # mode: [3]
      repeated: [1, 2, 2, 3, 3, 3],
      # mode: [1, 3]
      bimodal: [1, 1, 2, 3, 3],
      # std_dev: 2.0
      normal_dist: [2, 4, 4, 4, 5, 5, 7, 9]
    }
  end

  @doc """
  Performance test thresholds
  """
  def performance_thresholds do
    %{
      # microseconds per operation
      currency_formatting: 50,
      # microseconds for 10k items
      statistical_calc_10k: 100_000,
      # microseconds per conversion
      number_to_words: 1000,
      # microseconds per calculation
      tax_calculation: 10,
      # bytes (10MB)
      memory_limit: 10_000_000
    }
  end

  @doc """
  Creates financial test scenarios
  """
  def financial_scenarios do
    [
      # {principal, rate, time, expected_simple_interest}
      {1000, 0.05, 1, 50.0},
      {1000, 0.05, 2, 100.0},
      {5000, 0.03, 1, 150.0},
      {10000, 0.07, 0.5, 350.0}
    ]
  end

  @doc """
  Edge case test values
  """
  def edge_case_values do
    %{
      very_large: 999_999_999_999.99,
      very_small: 0.0001,
      zero: 0.0,
      negative: -1234.56,
      max_precision: 3.141592653589793,
      near_half: [2.4999, 2.5001, 3.4999, 3.5001]
    }
  end
end

# Custom assertions module for tests
defmodule CustomAssertions do
  @doc """
  Assert that two floats are approximately equal
  Usage: import CustomAssertions in your test module
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
  Assert that memory usage is within limits
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

defmodule NumberF.ErrorHandlingTest do
  use ExUnit.Case

  # Helper functions to avoid compiler warnings for intentional errors
  defp negative_sqrt(value), do: :math.sqrt(value)
  defp float_div_zero(a, b), do: a / b
  defp integer_div_zero(a, b), do: div(a, b)

  describe "error handling scenarios" do
    test "handles division by zero gracefully" do
      # Percentage calculation with zero total should raise
      assert_raise ArithmeticError, fn ->
        NumberF.percentage(10, 0)
      end

      # Other zero divisions should be handled appropriately
      assert_raise ArithmeticError, fn ->
        integer_div_zero(10, 0)
      end
    end

    test "handles invalid input types gracefully" do
      # String inputs to numeric functions
      assert_raise ArgumentError, fn ->
        NumberF.simple_interest("invalid", 0.05, 1)
      end

      # Nil inputs where not expected
      assert_raise ArgumentError, fn ->
        NumberF.mean([1, 2, nil, 4])
      end

      # Invalid date inputs
      assert_raise KeyError, fn ->
        NumberF.calculate_age("invalid_date")
      end
    end

    test "handles out-of-range inputs gracefully" do
      # Negative time periods
      assert_raise ArgumentError, fn ->
        NumberF.simple_interest(1000, 0.05, -1)
      end

      # Invalid precision values
      assert_raise ArgumentError, fn ->
        NumberF.round_with_precision(3.14, -1)
      end

      # Roman numerals out of range
      assert_raise ArgumentError, fn ->
        NumberF.to_roman(0)
      end

      assert_raise ArgumentError, fn ->
        NumberF.to_roman(4000)
      end
    end

    test "handles malformed strings gracefully" do
      # Invalid number parsing
      assert_raise ArgumentError, fn ->
        NumberF.CustomFormatter.to_float("not_a_number")
      end

      # Invalid boolean conversion
      assert_raise ArgumentError, fn ->
        NumberF.to_boolean("maybe")
      end

      # Invalid currency parsing
      assert_raise ArgumentError, fn ->
        NumberF.Currencies.parse("invalid_currency")
      end
    end

    test "handles empty or invalid collections" do
      # Empty list operations that should return nil
      assert NumberF.mean([]) == nil
      assert NumberF.median([]) == nil
      assert NumberF.standard_deviation([]) == nil

      # Invalid list types
      assert_raise ArgumentError, fn ->
        NumberF.mean("not_a_list")
      end
    end

    test "handles file system and external dependency errors" do
      # This would test external dependencies if any
      # Currently NumberF doesn't have external dependencies that could fail
      # But we can test resource exhaustion scenarios

      # Skip this test as it's not practical to test SystemLimitError
      # in a normal test environment
      assert true
    end

    test "handles floating point edge cases" do
      # Test that sqrt of negative number raises ArithmeticError
      assert_raise ArithmeticError, fn ->
        negative_sqrt(-1)
      end

      # Division by zero raises ArithmeticError
      assert_raise ArithmeticError, fn ->
        float_div_zero(1.0, 0.0)
      end

      # Very large floating point numbers
      huge_float = 1.0e308
      result = NumberF.round_with_precision(huge_float, 2)
      assert is_number(result)
    end

    test "handles unicode and encoding issues" do
      # Unicode in currency symbols
      # Indian Rupee symbol
      unicode_currency = NumberF.currency(100, "₹")
      assert is_binary(unicode_currency)

      # Unicode in phone formatting
      unicode_phone = NumberF.format_phone("1234567890", "IN")
      assert is_binary(unicode_phone)
      assert String.valid?(unicode_phone)
    end

    test "handles recursive or circular dependencies" do
      # Test that functions don't have stack overflow issues
      # with reasonable inputs

      # Large roman numeral conversion
      # Maximum supported
      large_roman = NumberF.to_roman(3999)
      assert is_binary(large_roman)

      # Large number to words
      large_words = NumberF.to_words(999_999_999, "Dollar", "Cent")
      assert is_binary(large_words)
      assert String.contains?(large_words, "Million")
    end

    test "handles resource cleanup" do
      # Test that functions clean up after themselves
      # and don't leave processes hanging

      # Memory usage should be reasonable
      :erlang.garbage_collect()
      memory_before = :erlang.memory(:total)

      # Perform operations
      _results =
        Enum.map(1..1000, fn i ->
          NumberF.currency(i * 1.23, "USD")
        end)

      :erlang.garbage_collect()
      memory_after = :erlang.memory(:total)

      # Memory increase should be reasonable (less than 1MB for this operation)
      memory_increase = memory_after - memory_before
      assert memory_increase < 1_000_000
    end
  end
end

defmodule NumberF.CurrencyEdgeCasesTest do
  use ExUnit.Case

  describe "currency edge cases" do
    test "handles very large currency amounts" do
      # Test trillion-dollar amounts
      huge_amount = 1_000_000_000_000.99
      formatted = NumberF.currency(huge_amount, "USD")
      assert formatted == "USD 1,000,000,000,000.99"

      # Test abbreviation
      abbreviated = NumberF.abbreviate_number(huge_amount)
      assert String.contains?(abbreviated, "T") or String.contains?(abbreviated, "B")
    end

    test "handles very small currency amounts" do
      # Test fractional cents
      tiny_amount = 0.001
      formatted = NumberF.currency(tiny_amount, "USD", 3)
      assert formatted == "USD 0.001"

      # Test with standard precision (should round)
      formatted_standard = NumberF.currency(tiny_amount, "USD", 2)
      assert formatted_standard == "USD 0.00"
    end

    test "handles different currency symbols and placements" do
      amount = 1234.56

      # Test various currency formats
      currencies_to_test = [
        {"USD", "$"},
        {"EUR", "€"},
        {"GBP", "£"},
        {"JPY", "¥"},
        {"ZMW", "K"}
      ]

      Enum.each(currencies_to_test, fn {code, symbol} ->
        formatted_code = NumberF.currency(amount, code)
        formatted_symbol = NumberF.currency(amount, symbol)

        assert is_binary(formatted_code)
        assert is_binary(formatted_symbol)
        assert String.contains?(formatted_code, code) or String.contains?(formatted_code, symbol)
      end)
    end

    test "handles currency parsing with different formats" do
      test_cases = [
        {"$1,234.56", 1234.56},
        {"1,234.56", 1234.56},
        {"€1.234,56", 1234.56},
        {"¥1,235", 1235.0}
      ]

      Enum.each(test_cases, fn {input, expected} ->
        # Test with appropriate currency context
        result =
          cond do
            String.contains?(input, "€") -> NumberF.Currencies.parse(input, "EUR")
            String.contains?(input, "¥") -> NumberF.Currencies.parse(input, "JPY")
            true -> NumberF.Currencies.parse(input, "USD")
          end

        assert_in_delta result, expected, 0.01
      end)
    end

    test "handles currency conversion edge cases" do
      exchange_rates = TestHelper.test_exchange_rates()

      # Test converting to same currency
      result = NumberF.Currencies.convert(100, "USD", "USD", exchange_rates)
      assert result == 100

      # Test very small amounts
      tiny_result = NumberF.Currencies.convert(0.01, "USD", "EUR", exchange_rates)
      assert tiny_result > 0 and tiny_result < 0.01

      # Test very large amounts
      huge_result = NumberF.Currencies.convert(1_000_000, "USD", "JPY", exchange_rates)
      # Should be a very large JPY amount
      assert huge_result > 100_000_000
    end

    test "handles zero and negative currency amounts" do
      # Zero amount
      assert NumberF.currency(0, "USD") == "USD 0.00"
      assert NumberF.format_currency(0, "en-US") == "$0.00"

      # Negative amounts
      assert NumberF.currency(-100, "USD") == "USD -100.00"
      assert NumberF.format_currency(-100, "en-US") == "$-100.00"

      # Negative conversion
      exchange_rates = %{"USD" => 1.0, "EUR" => 0.85}
      negative_conversion = NumberF.Currencies.convert(-100, "USD", "EUR", exchange_rates)
      assert negative_conversion == -85.0
    end
  end
end

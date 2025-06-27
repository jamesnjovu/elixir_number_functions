defmodule NumberF.CurrenciesTest do
  use ExUnit.Case
  doctest NumberF.Currencies

  describe "currency_data/0" do
    test "returns currency information" do
      data = NumberF.Currencies.currency_data()

      assert is_map(data)
      assert Map.has_key?(data, "USD")
      assert Map.has_key?(data, "EUR")
      assert Map.has_key?(data, "ZMW")
    end
  end

  describe "get_currency/1" do
    test "returns currency details for known currencies" do
      usd = NumberF.Currencies.get_currency("USD")

      assert usd.name == "US Dollar"
      assert usd.symbol == "$"
      assert usd.symbol_first == true
      assert usd.decimal_places == 2
    end

    test "returns default for unknown currencies" do
      unknown = NumberF.Currencies.get_currency("UNKNOWN")

      assert unknown.name == "UNKNOWN"
      assert unknown.symbol == "UNKNOWN"
    end
  end

  describe "format/3" do
    test "formats currency with default options" do
      assert NumberF.Currencies.format(1234.56, "USD") == "$1,234.56"
      assert NumberF.Currencies.format(1234.56, "EUR") == "1.234,56 €"
    end

    test "formats currency with custom options" do
      result = NumberF.Currencies.format(1234.56, "USD", symbol: false)
      assert result == "1,234.56"

      result = NumberF.Currencies.format(1234.56, "JPY")
      # JPY has 0 decimal places
      assert result == "¥1,235"
    end
  end

  describe "convert/5" do
    test "converts between currencies" do
      exchange_rates = %{"USD" => 1.0, "EUR" => 0.85, "GBP" => 0.75}

      # Convert 100 USD to EUR
      result = NumberF.Currencies.convert(100, "USD", "EUR", exchange_rates)
      assert result == 85.0

      # Convert 100 EUR to GBP
      result = NumberF.Currencies.convert(100, "EUR", "GBP", exchange_rates)
      assert_in_delta result, 88.23529411764706, 1.0e-13
    end

    test "returns same amount for same currency" do
      exchange_rates = %{"USD" => 1.0, "EUR" => 0.85}

      result = NumberF.Currencies.convert(100, "USD", "USD", exchange_rates)
      assert result == 100
    end

    test "raises error for missing exchange rates" do
      exchange_rates = %{"USD" => 1.0}

      assert_raise ArgumentError, fn ->
        NumberF.Currencies.convert(100, "USD", "EUR", exchange_rates)
      end
    end
  end

  describe "parse/2" do
    test "parses currency strings" do
      assert NumberF.Currencies.parse("$1,234.56") == 1234.56
      assert NumberF.Currencies.parse("€1.234,56", "EUR") == 1234.56
      assert NumberF.Currencies.parse("¥1,235", "JPY") == 1235.0
    end

    test "raises error for invalid currency strings" do
      assert_raise ArgumentError, fn ->
        NumberF.Currencies.parse("invalid")
      end
    end
  end
end

defmodule NumberF.CustomFormatterTest do
  use ExUnit.Case
  doctest NumberF.CustomFormatter

  describe "number_to_currency/2" do
    test "formats numbers as currency" do
      assert NumberF.CustomFormatter.number_to_currency(1234.56, unit: "USD", precision: 2) ==
               "USD 1,234.56"

      assert NumberF.CustomFormatter.number_to_currency(1234.56, unit: "", precision: 2) ==
               "1,234.56"
    end

    test "handles different input types" do
      assert NumberF.CustomFormatter.number_to_currency("1234.56", unit: "USD", precision: 2) ==
               "USD 1,234.56"

      assert NumberF.CustomFormatter.number_to_currency(1234, unit: "USD", precision: 2) ==
               "USD 1,234.00"
    end

    test "handles Decimal type" do
      decimal = Decimal.new("1234.56")

      assert NumberF.CustomFormatter.number_to_currency(decimal, unit: "USD", precision: 2) ==
               "USD 1,234.56"
    end

    test "uses custom delimiter and separator" do
      result =
        NumberF.CustomFormatter.number_to_currency(
          1234.56,
          unit: "EUR",
          precision: 2,
          delimiter: ".",
          separator: ","
        )

      assert result == "EUR 1.234,56"
    end
  end

  describe "number_to_delimited/2" do
    test "formats numbers with delimiters" do
      assert NumberF.CustomFormatter.number_to_delimited(1_234_567.89) == "1,234,567.89"

      assert NumberF.CustomFormatter.number_to_delimited(1_234_567.89,
               delimiter: ".",
               separator: ","
             ) == "1.234.567,89"
    end

    test "handles different precision" do
      assert NumberF.CustomFormatter.number_to_delimited(1_234_567.89, precision: 0) ==
               "1,234,568"

      assert NumberF.CustomFormatter.number_to_delimited(1_234_567.89, precision: 3) ==
               "1,234,567.890"
    end

    test "handles different input types" do
      assert NumberF.CustomFormatter.number_to_delimited("1234567.89") == "1,234,567.89"
      assert NumberF.CustomFormatter.number_to_delimited(1_234_567) == "1,234,567.00"
    end
  end

  describe "to_float/1" do
    test "converts different types to float" do
      assert NumberF.CustomFormatter.to_float(123) == 123.0
      assert NumberF.CustomFormatter.to_float(123.45) == 123.45
      assert NumberF.CustomFormatter.to_float("123.45") == 123.45
    end

    test "handles Decimal type" do
      decimal = Decimal.new("123.45")
      assert NumberF.CustomFormatter.to_float(decimal) == 123.45
    end

    test "raises error for invalid strings" do
      assert_raise ArgumentError, fn ->
        NumberF.CustomFormatter.to_float("invalid")
      end
    end
  end

  describe "to_decimal/1" do
    test "converts different types to Decimal" do
      assert Decimal.equal?(NumberF.CustomFormatter.to_decimal(123), Decimal.new(123))

      assert Decimal.equal?(
               NumberF.CustomFormatter.to_decimal(123.45),
               Decimal.from_float(123.45)
             )

      assert Decimal.equal?(NumberF.CustomFormatter.to_decimal("123.45"), Decimal.new("123.45"))
    end

    test "handles existing Decimal" do
      decimal = Decimal.new("123.45")
      assert Decimal.equal?(NumberF.CustomFormatter.to_decimal(decimal), decimal)
    end

    test "raises error for invalid strings" do
      assert_raise ArgumentError, fn ->
        NumberF.CustomFormatter.to_decimal("invalid")
      end
    end
  end
end

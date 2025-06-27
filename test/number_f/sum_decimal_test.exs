defmodule NumberF.SumDecimalTest do
  use ExUnit.Case

  describe "sum_decimal/1" do
    test "sums list of decimals" do
      decimals = [Decimal.new("1.2"), Decimal.new("3.4"), Decimal.new("5.6")]
      result = NumberF.sum_decimal(decimals)
      expected = Decimal.new("10.2")
      assert Decimal.equal?(result, expected)
    end

    test "sums nested list of decimals" do
      nested = [
        Decimal.new("1.2"),
        [Decimal.new("3.4"), Decimal.new("5.6")],
        Decimal.new("2.0")
      ]

      result = NumberF.sum_decimal(nested)
      expected = Decimal.new("12.2")
      assert Decimal.equal?(result, expected)
    end

    test "returns zero for empty list" do
      result = NumberF.sum_decimal([])
      expected = Decimal.new(0)
      assert Decimal.equal?(result, expected)
    end

    test "handles single decimal" do
      result = NumberF.sum_decimal([Decimal.new("42.5")])
      expected = Decimal.new("42.5")
      assert Decimal.equal?(result, expected)
    end

    test "handles deeply nested lists" do
      deeply_nested = [
        [Decimal.new("1.0"), [Decimal.new("2.0")]],
        [[Decimal.new("3.0")], Decimal.new("4.0")]
      ]

      result = NumberF.sum_decimal(deeply_nested)
      expected = Decimal.new("10.0")
      assert Decimal.equal?(result, expected)
    end
  end
end

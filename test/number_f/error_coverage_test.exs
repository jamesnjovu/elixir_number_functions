defmodule NumberF.ErrorCoverageTest do
  use ExUnit.Case

  describe "comprehensive error handling" do
    test "invalid arguments to main functions" do
      # Test all major functions with invalid inputs
      assert_raise ArgumentError, fn -> NumberF.simple_interest("invalid", 0.05, 1) end
      assert_raise ArgumentError, fn -> NumberF.simple_interest(1000, "invalid", 1) end
      assert_raise ArgumentError, fn -> NumberF.simple_interest(1000, 0.05, "invalid") end

      assert_raise ArgumentError, fn -> NumberF.compound_interest("invalid", 0.05, 1) end
      assert_raise ArgumentError, fn -> NumberF.calculate_emi("invalid", 0.05, 12) end

      assert_raise ArgumentError, fn -> NumberF.to_boolean("maybe") end
      assert_raise ArgumentError, fn -> NumberF.to_boolean("invalid") end

      assert_raise ArgumentError, fn -> NumberF.to_roman(0) end
      assert_raise ArgumentError, fn -> NumberF.to_roman(4000) end
      assert_raise ArgumentError, fn -> NumberF.to_roman(-1) end
    end

    test "edge cases in mathematical functions" do
      # Negative time should raise error
      assert_raise ArgumentError, fn -> NumberF.simple_interest(1000, 0.05, -1) end

      # Invalid mean input
      assert_raise ArgumentError, fn -> NumberF.mean("not a list") end
      assert_raise ArgumentError, fn -> NumberF.mean([1, 2, "invalid", 4]) end
    end

    test "division by zero scenarios" do
      assert_raise ArithmeticError, fn -> NumberF.percentage(10, 0) end
    end
  end
end

defmodule NumberF.RoundingTest do
  use ExUnit.Case

  describe "comprehensive rounding tests" do
    test "standard rounding edge cases" do
      # Test exact halves
      assert NumberF.round_with_precision(2.5, 0) == 3.0
      assert NumberF.round_with_precision(3.5, 0) == 4.0
      assert NumberF.round_with_precision(-2.5, 0) == -3.0

      # Test near halves
      assert NumberF.round_with_precision(2.4999, 0) == 2.0
      assert NumberF.round_with_precision(2.5001, 0) == 3.0
    end

    test "banker's rounding implementation" do
      # Even numbers should round down when exactly half
      assert NumberF.bankers_round(2.5, 0) == 2.0
      assert NumberF.bankers_round(4.5, 0) == 4.0

      # Odd numbers should round up when exactly half
      assert NumberF.bankers_round(3.5, 0) == 4.0
      assert NumberF.bankers_round(5.5, 0) == 6.0

      # Non-halves should round normally
      assert NumberF.bankers_round(2.3, 0) == 2.0
      assert NumberF.bankers_round(2.7, 0) == 3.0
    end

    test "precision rounding with various decimal places" do
      number = 3.14159265359

      assert NumberF.round_with_precision(number, 0) == 3.0
      assert NumberF.round_with_precision(number, 1) == 3.1
      assert NumberF.round_with_precision(number, 2) == 3.14
      assert NumberF.round_with_precision(number, 3) == 3.142
      assert NumberF.round_with_precision(number, 4) == 3.1416
      assert NumberF.round_with_precision(number, 5) == 3.14159
    end

    test "ceiling and floor precision" do
      number = 3.14159

      # Ceiling should always round up
      assert NumberF.ceiling(number, 2) == 3.15
      assert NumberF.ceiling(number, 1) == 3.2
      # Exact values stay the same
      assert NumberF.ceiling(3.1, 1) == 3.1

      # Floor should always round down
      assert NumberF.floor(number, 2) == 3.14
      assert NumberF.floor(number, 1) == 3.1
      assert NumberF.floor(3.9, 0) == 3.0
    end

    test "round to increment functionality" do
      # Round to nearest 0.05
      assert NumberF.round_to(3.14159, 0.05, :nearest) == 3.15
      assert NumberF.round_to(3.12, 0.05, :nearest) == 3.10
      assert NumberF.round_to(3.17, 0.05, :nearest) == 3.15

      # Round to nearest 0.25
      assert NumberF.round_to(3.1, 0.25, :nearest) == 3.0
      assert NumberF.round_to(3.2, 0.25, :nearest) == 3.25
      assert NumberF.round_to(3.4, 0.25, :nearest) == 3.5

      # Round up to increment
      assert NumberF.round_to(3.01, 0.05, :up) == 3.05
      assert NumberF.round_to(3.00, 0.05, :up) == 3.0

      # Round down to increment
      assert NumberF.round_to(3.19, 0.05, :down) == 3.15
      assert NumberF.round_to(3.20, 0.05, :down) == 3.2
    end
  end
end

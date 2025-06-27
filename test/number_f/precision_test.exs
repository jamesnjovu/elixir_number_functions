defmodule NumberF.PrecisionTest do
  use ExUnit.Case
  doctest NumberF.Precision

  describe "round_with_precision/2" do
    test "rounds with specified precision" do
      assert NumberF.Precision.round_with_precision(3.14159, 2) == 3.14
      assert NumberF.Precision.round_with_precision(3.14159, 4) == 3.1416
      assert NumberF.Precision.round_with_precision(3.14159, 0) == 3.0
    end
  end

  describe "bankers_round/2" do
    test "uses banker's rounding" do
      assert NumberF.Precision.bankers_round(2.5, 0) == 2.0
      assert NumberF.Precision.bankers_round(3.5, 0) == 4.0
      assert NumberF.Precision.bankers_round(2.125, 2) == 2.12
      assert NumberF.Precision.bankers_round(2.135, 2) == 2.14
    end
  end

  describe "ceiling/2" do
    test "rounds up to precision" do
      assert NumberF.Precision.ceiling(3.14159, 2) == 3.15
      assert NumberF.Precision.ceiling(3.14159, 1) == 3.2
      assert NumberF.Precision.ceiling(3.1, 1) == 3.1
    end
  end

  describe "floor/2" do
    test "rounds down to precision" do
      assert NumberF.Precision.floor(3.14159, 2) == 3.14
      assert NumberF.Precision.floor(3.14159, 1) == 3.1
      assert NumberF.Precision.floor(3.9, 0) == 3.0
    end
  end

  describe "truncate/2" do
    test "truncates to precision" do
      assert NumberF.Precision.truncate(3.14159, 2) == 3.14
      assert NumberF.Precision.truncate(-3.14159, 2) == -3.14
      assert NumberF.Precision.truncate(3.99999, 2) == 3.99
    end
  end

  describe "round_to/3" do
    test "rounds to specific increment" do
      assert NumberF.Precision.round_to(3.14159, 0.05, :nearest) == 3.15
      assert NumberF.Precision.round_to(3.14159, 0.1, :up) == 3.2
      assert NumberF.Precision.round_to(3.14159, 0.1, :down) == 3.1
    end
  end

  describe "approximately_equal/3" do
    test "checks floating point equality" do
      assert NumberF.Precision.approximately_equal(0.1 + 0.2, 0.3) == true
      assert NumberF.Precision.approximately_equal(0.1, 0.2) == false
      assert NumberF.Precision.approximately_equal(1.0000001, 1.0000002, 1.0e-6) == true
    end
  end

  describe "custom_round/3" do
    test "rounds with different modes" do
      assert NumberF.Precision.custom_round(2.5, 0, :half_up) == 3.0
      assert NumberF.Precision.custom_round(2.5, 0, :half_down) == 2.0
      assert NumberF.Precision.custom_round(2.5, 0, :half_even) == 2.0
      assert NumberF.Precision.custom_round(3.5, 0, :half_even) == 4.0
      assert NumberF.Precision.custom_round(3.7, 0, :ceiling) == 4.0
      assert NumberF.Precision.custom_round(3.7, 0, :floor) == 3.0
    end
  end

  describe "sanitize_float/2" do
    test "sanitizes special float values" do
      assert NumberF.Precision.sanitize_float(:nan, 0.0) == 0.0
      assert NumberF.Precision.sanitize_float(:infinity, 0.0) == 0.0
      assert NumberF.Precision.sanitize_float(:"-infinity", 0.0) == 0.0
      assert NumberF.Precision.sanitize_float(3.14, 0.0) == 3.14
      assert NumberF.Precision.sanitize_float(42, 0.0) == 42.0
    end
  end
end

defmodule NumberF.StatisticsTest do
  use ExUnit.Case
  doctest NumberF.Statistics

  describe "mean/1" do
    test "calculates arithmetic mean" do
      assert NumberF.Statistics.mean([1, 2, 3, 4, 5]) == 3.0
      assert NumberF.Statistics.mean([10, 20, 30]) == 20.0
      assert NumberF.Statistics.mean([1.5, 2.5, 3.5]) == 2.5
    end

    test "returns nil for empty list" do
      assert NumberF.Statistics.mean([]) == nil
    end
  end

  describe "median/1" do
    test "calculates median for odd number of elements" do
      assert NumberF.Statistics.median([1, 3, 5, 7, 9]) == 5
      assert NumberF.Statistics.median([1]) == 1
    end

    test "calculates median for even number of elements" do
      assert NumberF.Statistics.median([1, 3, 5, 7]) == 4.0
      assert NumberF.Statistics.median([2, 4]) == 3.0
    end

    test "returns nil for empty list" do
      assert NumberF.Statistics.median([]) == nil
    end
  end

  describe "mode/1" do
    test "finds single mode" do
      assert NumberF.Statistics.mode([1, 2, 2, 3, 3, 3, 4]) == [3]
      assert NumberF.Statistics.mode([1, 1, 1, 2, 3]) == [1]
    end

    test "finds multiple modes" do
      assert NumberF.Statistics.mode([1, 1, 2, 2, 3]) == [1, 2]
      assert NumberF.Statistics.mode([1, 2, 3]) == [1, 2, 3]
    end

    test "returns empty list for empty input" do
      assert NumberF.Statistics.mode([]) == []
    end
  end

  describe "standard_deviation/1" do
    test "calculates standard deviation" do
      assert NumberF.Statistics.standard_deviation([2, 4, 4, 4, 5, 5, 7, 9]) == 2.0
    end

    test "returns 0 for single element" do
      assert NumberF.Statistics.standard_deviation([5]) == 0.0
    end

    test "returns nil for empty list" do
      assert NumberF.Statistics.standard_deviation([]) == nil
    end
  end

  describe "variance/1" do
    test "calculates variance" do
      assert NumberF.Statistics.variance([2, 4, 4, 4, 5, 5, 7, 9]) == 4.0
    end

    test "returns 0 for single element" do
      assert NumberF.Statistics.variance([5]) == 0.0
    end

    test "returns nil for empty list" do
      assert NumberF.Statistics.variance([]) == nil
    end
  end

  describe "range/1" do
    test "calculates range" do
      assert NumberF.Statistics.range([2, 4, 4, 4, 5, 5, 7, 9]) == 7.0
      assert NumberF.Statistics.range([1, 10]) == 9.0
    end

    test "returns 0 for single element" do
      assert NumberF.Statistics.range([5]) == 0.0
    end

    test "returns nil for empty list" do
      assert NumberF.Statistics.range([]) == nil
    end
  end
end

defmodule NumberF.FinancialTest do
  use ExUnit.Case
  doctest NumberF.Financial

  describe "simple_interest/3" do
    test "calculates simple interest" do
      assert NumberF.Financial.simple_interest(1000, 0.05, 2) == 100.0
      assert NumberF.Financial.simple_interest(5000, 0.03, 1) == 150.0
      assert NumberF.Financial.simple_interest(10000, 0.07, 0.5) == 350.0
    end
  end

  describe "compound_interest/4" do
    test "calculates compound interest with annual compounding" do
      assert NumberF.Financial.compound_interest(1000, 0.05, 2, 1) == 102.5
      assert NumberF.Financial.compound_interest(1000, 0.1, 1, 1) == 100.0
    end

    test "calculates compound interest with different frequencies" do
      # Monthly compounding
      result = NumberF.Financial.compound_interest(1000, 0.05, 2, 12)
      assert result == 104.94

      # Quarterly compounding
      result = NumberF.Financial.compound_interest(1000, 0.08, 1, 4)
      assert result == 82.43
    end
  end

  describe "calculate_emi/3" do
    test "calculates EMI correctly" do
      assert NumberF.Financial.calculate_emi(100_000, 0.10, 12) == 8791.59
      assert NumberF.Financial.calculate_emi(50000, 0.05, 24) == 2193.57
    end
  end

  describe "convert_currency/3" do
    test "converts currency based on exchange rates" do
      assert NumberF.Financial.convert_currency(100, 1, 1.1) == 110.0
      assert NumberF.Financial.convert_currency(100, 2, 1) == 50.0
    end
  end
end

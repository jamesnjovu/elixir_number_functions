defmodule NumberF.FinancialEdgeCasesTest do
  use ExUnit.Case

  describe "financial calculation edge cases" do
    test "handles extreme interest rates" do
      principal = 1000

      # Very low interest rate
      low_rate_interest = NumberF.simple_interest(principal, 0.0001, 1)
      assert low_rate_interest == 0.1

      # Very high interest rate
      high_rate_interest = NumberF.simple_interest(principal, 2.0, 1)
      assert high_rate_interest == 2000.0

      # Zero interest rate
      zero_rate_interest = NumberF.simple_interest(principal, 0.0, 1)
      assert zero_rate_interest == 0.0
    end

    test "handles extreme time periods" do
      principal = 1000
      rate = 0.05

      # Very short time period
      # 0.01 years
      short_time = NumberF.simple_interest(principal, rate, 0.01)
      assert short_time == 0.5

      # Very long time period
      # 100 years
      long_time = NumberF.simple_interest(principal, rate, 100)
      assert long_time == 5000.0

      # Zero time period
      zero_time = NumberF.simple_interest(principal, rate, 0)
      assert zero_time == 0.0
    end

    test "handles compound interest with extreme frequencies" do
      principal = 1000
      rate = 0.05
      time = 1

      # Daily compounding
      daily = NumberF.compound_interest(principal, rate, time, 365)
      assert daily > 51.0 and daily < 52.0

      # Hourly compounding
      # 24 * 365
      hourly = NumberF.compound_interest(principal, rate, time, 8760)
      assert hourly >= daily

      # Very frequent compounding should approach continuous compounding
      very_frequent = NumberF.compound_interest(principal, rate, time, 1_000_000)
      continuous_approximation = principal * (:math.exp(rate * time) - 1)
      assert_in_delta very_frequent, continuous_approximation, 0.1
    end

    test "handles EMI calculation edge cases" do
      principal = 100_000

      # Very short loan term
      # 1 month
      short_emi = NumberF.calculate_emi(principal, 0.12, 1)
      # Should be more than principal due to interest
      assert short_emi > principal

      # Very long loan term
      # 30 years
      long_emi = NumberF.calculate_emi(principal, 0.12, 360)
      # Should be reasonable monthly payment
      assert long_emi > 0 and long_emi < 2000

      # Very low interest rate
      # 0.1% annual
      low_rate_emi = NumberF.calculate_emi(principal, 0.001, 12)
      # Should be close to principal/12
      assert low_rate_emi < 8500

      # Very high interest rate
      # 50% annual
      high_rate_emi = NumberF.calculate_emi(principal, 0.5, 12)
      # Should be significantly higher
      assert high_rate_emi > 10000
    end

    test "handles currency conversion with extreme rates" do
      amount = 100

      # Very unfavorable exchange rate
      unfavorable = NumberF.convert_currency(amount, 1, 0.001)
      assert unfavorable == 0.1

      # Very favorable exchange rate
      favorable = NumberF.convert_currency(amount, 1, 1000)
      assert favorable == 100_000.0

      # Equal rates
      equal = NumberF.convert_currency(amount, 1, 1)
      assert equal == 100.0

      # Inverse rates
      forward = NumberF.convert_currency(amount, 1, 2)
      backward = NumberF.convert_currency(forward, 2, 1)
      assert_in_delta backward, amount, 0.001
    end

    test "handles financial calculations with very large principals" do
      # 1 trillion
      huge_principal = 1_000_000_000_000

      # Simple interest should scale linearly
      interest = NumberF.simple_interest(huge_principal, 0.05, 1)
      # 50 billion
      assert interest == 50_000_000_000.0

      # Compound interest should also work
      compound = NumberF.compound_interest(huge_principal, 0.05, 1, 1)
      # Should be same for 1 year, annual compounding
      assert compound == interest

      # EMI calculation
      emi = NumberF.calculate_emi(huge_principal, 0.05, 360)
      # Should be reasonable monthly payment for such amount
      assert emi > 5_000_000
    end

    test "handles financial calculations with very small principals" do
      # 1 dollar (still small but not too small to be rounded to 0)
      tiny_principal = 1.0

      # Simple interest
      interest = NumberF.simple_interest(tiny_principal, 0.05, 1)
      assert_in_delta interest, 0.05, 0.01

      # Compound interest
      compound = NumberF.compound_interest(tiny_principal, 0.05, 1, 12)
      assert compound >= interest and compound < 0.1

      # EMI calculation
      emi = NumberF.calculate_emi(tiny_principal, 0.05, 12)
      assert emi > 0 and emi < 1.0
    end
  end
end

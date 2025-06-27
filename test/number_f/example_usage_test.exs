defmodule NumberF.ExampleUsageTest do
  use ExUnit.Case
  # Import custom assertions
  import CustomAssertions

  describe "example usage of test helpers" do
    test "using TestHelper functions" do
      # Generate test data
      test_data = TestHelper.generate_test_data(10)
      assert test_data == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

      # Test statistical functions with generated data
      mean_result = NumberF.mean(test_data)
      assert mean_result == 5.5

      # Use float comparison helper
      std_dev = NumberF.standard_deviation(test_data)
      assert TestHelper.float_equal?(std_dev, 3.03, 0.01)
    end

    test "using custom assertions for float comparison" do
      result = NumberF.percentage(1, 3, 4)
      assert_float_equal(result, 33.3333, 0.0001)
    end

    test "using performance assertion" do
      assert_performance(50_000) do
        # This should complete quickly
        Enum.each(1..100, fn i ->
          NumberF.currency(i * 1.23, "USD")
        end)
      end
    end

    test "using memory assertion" do
      # 1MB limit
      assert_memory_usage(1_000_000) do
        # This should not use excessive memory
        large_list = TestHelper.generate_test_data(1000)
        _mean = NumberF.mean(large_list)
        _median = NumberF.median(large_list)
      end
    end

    test "using test currency data" do
      exchange_rates = TestHelper.test_exchange_rates()

      # Convert 100 USD to EUR
      eur_amount = NumberF.Currencies.convert(100, "USD", "EUR", exchange_rates)
      assert eur_amount == 85.0
    end

    test "using test phone numbers" do
      phone_numbers = TestHelper.test_phone_numbers()
      us_numbers = phone_numbers["US"]

      Enum.each(us_numbers, fn number ->
        formatted = NumberF.format_phone(number, "US")
        assert is_binary(formatted)
        assert String.length(formatted) > 0
      end)
    end

    test "using edge case values" do
      edge_cases = TestHelper.edge_case_values()

      # Test with very large number
      large_formatted = NumberF.currency(edge_cases.very_large, "USD")
      assert String.contains?(large_formatted, "999,999,999,999.99")

      # Test with zero
      zero_formatted = NumberF.currency(edge_cases.zero, "USD")
      assert zero_formatted == "USD 0.00"

      # Test with negative
      negative_formatted = NumberF.currency(edge_cases.negative, "USD")
      assert negative_formatted == "USD -1,234.56"
    end

    test "using statistical test data" do
      test_data = TestHelper.statistical_test_data()

      # Test with simple dataset
      simple_mean = NumberF.mean(test_data.simple)
      assert simple_mean == 3.0

      # Test with dataset containing outliers
      outlier_median = NumberF.median(test_data.with_outliers)
      # Median is robust to outliers
      assert outlier_median == 3

      # Test with known standard deviation
      normal_std = NumberF.standard_deviation(test_data.normal_dist)
      assert normal_std == 2.0
    end

    test "using financial scenarios" do
      scenarios = TestHelper.financial_scenarios()

      Enum.each(scenarios, fn {principal, rate, time, expected_interest} ->
        actual_interest = NumberF.simple_interest(principal, rate, time)
        assert actual_interest == expected_interest
      end)
    end

    test "measuring execution time with helper" do
      {time, result} =
        TestHelper.measure_time(fn ->
          NumberF.mean(TestHelper.generate_test_data(1000))
        end)

      assert is_number(result)
      # Should complete in less than 10ms
      assert time < 10_000
    end

    test "using performance thresholds" do
      thresholds = TestHelper.performance_thresholds()

      # Test currency formatting performance
      {time, _} =
        TestHelper.measure_time(fn ->
          NumberF.currency(1234.56, "USD")
        end)

      # Should be faster than threshold
      assert time < thresholds.currency_formatting
    end

    test "using range assertion" do
      percentage_result = NumberF.percentage(25, 100)
      assert_in_range(percentage_result, 24.9, 25.1)
    end
  end
end

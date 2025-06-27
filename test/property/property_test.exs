defmodule NumberF.PropertyTest do
  use ExUnit.Case

  describe "property-based tests" do
    @describetag :property
    test "currency formatting is reversible with parsing" do
      # Generate random amounts
      amounts = TestHelper.random_numbers(100)

      Enum.each(amounts, fn amount ->
        # Format and then parse back
        formatted = NumberF.currency(amount, "USD")

        # Should contain the original amount (allowing for rounding)
        assert String.contains?(formatted, "USD")

        # Extract number part and verify it's close to original
        number_part =
          formatted
          |> String.replace("USD ", "")
          |> String.replace(",", "")

        {parsed, _} = Float.parse(number_part)
        assert_in_delta parsed, amount, 0.01
      end)
    end

    test "percentage calculations are consistent" do
      values = TestHelper.random_numbers(50)
      # Avoid zero
      totals = TestHelper.random_numbers(50) |> Enum.map(&(&1 + 1))

      Enum.zip(values, totals)
      |> Enum.each(fn {value, total} ->
        percentage = NumberF.percentage(value, total)

        # Percentage should be between 0 and 100 (allowing for values > total)
        assert is_number(percentage)
        assert percentage >= 0.0 or value > total

        # Reverse calculation should work
        calculated_value = total * percentage / 100
        assert_in_delta calculated_value, value, 0.01
      end)
    end

    test "statistical functions are mathematically consistent" do
      datasets =
        Enum.map(1..20, fn _ ->
          TestHelper.random_numbers(10)
        end)

      Enum.each(datasets, fn data ->
        mean = NumberF.mean(data)
        median = NumberF.median(data)

        # Mean should be a number
        assert is_number(mean)

        # Median should be within the range of the data
        min_val = Enum.min(data)
        max_val = Enum.max(data)
        assert median >= min_val
        assert median <= max_val

        # Standard deviation should be non-negative
        std_dev = NumberF.standard_deviation(data)
        assert std_dev >= 0.0
      end)
    end

    test "unit conversions are reversible" do
      values = TestHelper.random_numbers(50)

      Enum.each(values, fn value ->
        # Test temperature conversion reversibility
        celsius = value
        fahrenheit = NumberF.celsius_to_fahrenheit(celsius)
        back_to_celsius = NumberF.fahrenheit_to_celsius(fahrenheit)
        assert_in_delta back_to_celsius, celsius, 0.01

        # Test distance conversion reversibility
        miles = value
        kilometers = NumberF.miles_to_km(miles)
        back_to_miles = NumberF.km_to_miles(kilometers)
        assert_in_delta back_to_miles, miles, 0.01

        # Test length conversion reversibility
        inches = value
        centimeters = NumberF.inches_to_cm(inches)
        back_to_inches = NumberF.cm_to_inches(centimeters)
        assert_in_delta back_to_inches, inches, 0.01
      end)
    end
  end
end

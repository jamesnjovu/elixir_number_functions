defmodule NumberFIntegrationTest do
  use ExUnit.Case

  describe "integration tests" do
    test "currency formatting with various inputs" do
      # Test with different numeric types
      assert NumberF.currency(1234) == "ZMW 1,234.00"
      assert NumberF.currency(1234.5) == "ZMW 1,234.50"
      assert NumberF.currency(1234.567) == "ZMW 1,234.57"

      # Test with nil input
      assert NumberF.currency(nil) == nil

      # Test with different currencies
      assert NumberF.currency(1234.56, "USD") == "USD 1,234.56"
      assert NumberF.currency(1234.56, "€") == "€ 1,234.56"
    end

    test "number conversion pipeline" do
      # Convert to words then validate the number
      number = 1234.56
      words = NumberF.to_words(number, "Dollars", "Cents")
      assert String.contains?(words, "One Thousand Two Hundred Thirty Four Dollars")

      # Format as currency
      currency = NumberF.currency(number, "USD")
      assert currency == "USD 1,234.56"

      # Create abbreviated form
      abbreviated = NumberF.abbreviate_number(number * 1000)
      assert abbreviated == "1.2M"
    end

    test "financial calculations workflow" do
      principal = 100_000
      rate = 0.05
      time = 30

      # Calculate simple interest
      simple_interest = NumberF.simple_interest(principal, rate, time)
      assert simple_interest == 150_000.0

      # Calculate compound interest (annual)
      compound_interest = NumberF.compound_interest(principal, rate, time)
      assert compound_interest == 332_194.24

      # Calculate EMI for a loan
      emi = NumberF.calculate_emi(principal, rate, 360)
      assert emi == 536.82

      # Format results
      assert NumberF.currency(emi, "USD") == "USD 536.82"
    end

    test "statistical analysis workflow" do
      data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

      # Calculate statistics
      mean = NumberF.mean(data)
      median = NumberF.median(data)
      std_dev = NumberF.standard_deviation(data)

      assert mean == 5.5
      assert median == 5.5
      assert_in_delta std_dev, 3.03, 0.2

      # Format results
      assert NumberF.percentage(mean, 10) == 55.0
      assert NumberF.round_with_precision(std_dev, 2) == 2.87
    end

    test "international formatting workflow" do
      amount = 1_234_567.89

      # Format for different locales
      us_format = NumberF.format_number(amount, "en-US")
      fr_format = NumberF.format_number(amount, "fr-FR")
      de_format = NumberF.format_number(amount, "de-DE")

      assert us_format == "1,234,567.89"
      assert fr_format == "1 234 567,89"
      assert de_format == "1.234.567,89"

      # Format currency for different locales
      us_currency = NumberF.format_currency(1234.56, "en-US")
      fr_currency = NumberF.format_currency(1234.56, "fr-FR")

      assert us_currency == "$1,234.56"
      assert fr_currency == "1 234,56 €"
    end

    test "validation and conversion workflow" do
      # Validate different inputs
      assert NumberF.is_valid_number?("123.45") == true
      assert NumberF.is_valid_integer?("123") == true
      assert NumberF.is_valid_credit_card?("4111111111111111") == true

      # Convert valid inputs
      assert NumberF.to_float("123.45") == 123.45
      assert NumberF.to_int("123") == 123
      assert NumberF.to_boolean("true") == true
    end

    test "tax calculation workflow" do
      amount = 1000

      # Calculate different types of taxes
      vat = NumberF.calculate_vat(amount, 0.2)
      sales_tax = NumberF.calculate_sales_tax(amount, 0.06)

      assert vat.net == 1000.0
      assert vat.vat == 200.0
      assert vat.gross == 1200.0

      assert sales_tax.subtotal == 1000.0
      assert sales_tax.tax == 60.0
      assert sales_tax.total == 1060.0

      # Format tax amounts
      assert NumberF.currency(vat.gross, "USD") == "USD 1,200.00"
    end

    test "unit conversion workflow" do
      # Temperature conversion
      celsius = 25
      fahrenheit = NumberF.celsius_to_fahrenheit(celsius)
      assert fahrenheit == 77.0

      # Distance conversion
      miles = 10
      kilometers = NumberF.miles_to_km(miles)
      assert kilometers == 16.09

      # Back conversion should be close to original
      back_to_miles = NumberF.km_to_miles(kilometers)
      assert_in_delta back_to_miles, miles, 0.01
    end

    test "memory and randomization utilities" do
      # Memory size formatting
      assert NumberF.memory_size_cal(1024) == "1.0 KB"
      assert NumberF.memory_size_cal(1_048_576) == "1.0 MB"

      # Random string generation
      random_str = NumberF.randomizer(10)
      assert String.length(random_str) == 10

      password = NumberF.default_password()
      assert String.match?(password, ~r/^[A-Z][a-z]{2}@[0-9]{4}$/)
    end

    test "date calculations workflow" do
      # Age calculation
      today = Date.utc_today()
      birth_date = %{today | year: today.year - 25}
      age = NumberF.calculate_age(birth_date)
      assert age == 25

      # Payment due date
      invoice_date = ~D[2023-01-15]
      due_date = NumberF.payment_due_date(invoice_date, 30)
      assert due_date == ~D[2023-02-14]

      # Business days calculation
      monday = ~D[2023-01-02]
      friday = ~D[2023-01-06]
      business_days = NumberF.business_days_between(monday, friday)
      assert business_days == 5
    end

    test "precision handling workflow" do
      number = 3.14159265359

      # Different rounding strategies
      standard_round = NumberF.round_with_precision(number, 2)
      bankers_round = NumberF.bankers_round(2.5, 0)
      ceiling_round = NumberF.ceiling(number, 2)
      floor_round = NumberF.floor(number, 2)

      assert standard_round == 3.14
      assert bankers_round == 2.0
      assert ceiling_round == 3.15
      assert floor_round == 3.14

      # Floating point comparison
      assert NumberF.approximately_equal(0.1 + 0.2, 0.3) == true
    end

    test "error handling" do
      # Division by zero protection in percentage
      assert_raise ArithmeticError, fn ->
        NumberF.percentage(10, 0)
      end

      # Invalid conversion
      assert_raise ArgumentError, fn ->
        NumberF.to_boolean("invalid")
      end

      # Invalid credit card
      assert NumberF.is_valid_credit_card?("invalid") == false

      # Invalid number format
      assert NumberF.is_valid_number?("abc") == false
    end
  end
end

defmodule NumberF.RealWorldScenariosTest do
  use ExUnit.Case

  describe "real world scenarios" do
    test "e-commerce price calculation scenario" do
      # Product pricing scenario
      base_price = 99.99
      discount_rate = 0.15
      tax_rate = 0.08

      # Calculate discounted price
      discount_amount = base_price * discount_rate
      discounted_price = base_price - discount_amount

      # Calculate tax
      tax_result = NumberF.calculate_sales_tax(discounted_price, tax_rate)
      final_price = tax_result.total

      # Format for display
      formatted_base = NumberF.currency(base_price, "USD")
      formatted_discount = NumberF.currency(discount_amount, "USD")
      formatted_final = NumberF.currency(final_price, "USD")

      # Convert to words for check writing
      price_in_words = NumberF.to_words(final_price, "Dollars", "Cents")

      # Assertions
      assert formatted_base == "USD 99.99"
      assert_in_delta discount_amount, 15.00, 0.01
      assert_in_delta final_price, 91.79, 0.01
      assert formatted_final == "USD 91.79"
      assert String.contains?(price_in_words, "Ninety One Dollars")
    end

    test "loan amortization scenario" do
      # 30-year mortgage scenario
      loan_amount = 300_000
      # 4.5%
      annual_rate = 0.045
      # 30 years
      term_months = 360

      # Calculate monthly payment
      monthly_payment = NumberF.calculate_emi(loan_amount, annual_rate, term_months)

      # Calculate total interest paid
      total_payments = monthly_payment * term_months
      total_interest = total_payments - loan_amount

      # Calculate first month's interest and principal
      monthly_rate = annual_rate / 12
      first_month_interest = loan_amount * monthly_rate
      first_month_principal = monthly_payment - first_month_interest

      # Format results
      formatted_loan = NumberF.currency(loan_amount, "USD")
      formatted_payment = NumberF.currency(monthly_payment, "USD")
      formatted_total_interest = NumberF.currency(total_interest, "USD")

      # Calculate percentage of payment going to interest in first month
      interest_percentage = NumberF.percentage(first_month_interest, monthly_payment, 1)

      # Assertions
      assert formatted_loan == "USD 300,000.00"
      assert_in_delta monthly_payment, 1520.06, 1.0
      assert_in_delta total_interest, 247_220.13, 100.0
      # Most of first payment is interest
      assert interest_percentage > 70.0
    end

    test "investment portfolio analysis scenario" do
      # Portfolio with different investments
      investments = [
        # Stock investment
        {10_000, 0.07, 5},
        # Bond investment
        {5_000, 0.04, 5},
        # High-risk investment
        {15_000, 0.12, 5}
      ]

      # Calculate future values with compound interest
      future_values =
        Enum.map(investments, fn {principal, rate, years} ->
          interest = NumberF.compound_interest(principal, rate, years, 1)
          principal + interest
        end)

      # Calculate total portfolio value
      total_future_value = Enum.sum(future_values)
      total_invested = 30_000
      total_gain = total_future_value - total_invested

      # Calculate portfolio statistics
      portfolio_return_rate = NumberF.percentage(total_gain, total_invested, 2)

      # Calculate mean return
      returns =
        Enum.zip(investments, future_values)
        |> Enum.map(fn {{principal, _, _}, future_value} ->
          NumberF.percentage(future_value - principal, principal, 2)
        end)

      mean_return = NumberF.mean(returns)
      std_dev_return = NumberF.standard_deviation(returns)

      # Format results
      formatted_total = NumberF.currency(total_future_value, "USD")
      formatted_gain = NumberF.currency(total_gain, "USD")

      # Assertions
      assert total_future_value > total_invested
      assert portfolio_return_rate > 0
      assert mean_return > 0
      assert std_dev_return > 0
      assert String.contains?(formatted_total, "USD")
    end

    test "international business transaction scenario" do
      # Multi-currency business transaction
      base_amount_usd = 50_000

      exchange_rates = %{
        "USD" => 1.0,
        "EUR" => 0.85,
        "GBP" => 0.73,
        "JPY" => 110.0,
        "ZMW" => 20.5
      }

      # Convert to different currencies
      currencies = ["EUR", "GBP", "JPY", "ZMW"]

      converted_amounts =
        Enum.map(currencies, fn currency ->
          {currency, NumberF.Currencies.convert(base_amount_usd, "USD", currency, exchange_rates)}
        end)

      # Format for different locales
      formatted_amounts =
        Enum.map(converted_amounts, fn {currency, amount} ->
          locale =
            case currency do
              "EUR" -> "de-DE"
              "GBP" -> "en-GB"
              "JPY" -> "ja-JP"
              "ZMW" -> "en-ZM"
            end

          {currency, NumberF.format_currency(amount, locale)}
        end)

      # Calculate VAT for European transactions
      eur_amount =
        Enum.find_value(converted_amounts, fn
          {"EUR", amount} -> amount
          _ -> nil
        end)

      # German VAT rate
      vat_calculation = NumberF.calculate_vat(eur_amount, 0.19)

      # Assertions
      assert length(formatted_amounts) == 4

      Enum.each(formatted_amounts, fn {_currency, formatted} ->
        assert is_binary(formatted)
        assert String.length(formatted) > 0
      end)

      assert vat_calculation.net == eur_amount
      assert vat_calculation.vat > 0
    end

    test "payroll processing scenario" do
      # Employee payroll calculation
      annual_salary = 75_000
      monthly_salary = annual_salary / 12

      # Calculate various deductions
      federal_tax_brackets = [
        {0, 0.10},
        {9_950, 0.12},
        {40_525, 0.22},
        {86_375, 0.24}
      ]

      # Calculate annual federal tax
      federal_tax = NumberF.Tax.calculate_income_tax(annual_salary, federal_tax_brackets)
      monthly_federal_tax = federal_tax.tax / 12

      # Calculate payroll taxes (Social Security + Medicare)
      payroll_tax =
        NumberF.Tax.calculate_payroll_tax(monthly_salary, 0.062 + 0.0145, 0.062 + 0.0145)

      # Calculate take-home pay
      monthly_take_home = monthly_salary - monthly_federal_tax - payroll_tax.employee_contribution

      # Calculate savings potential (20% of take-home)
      monthly_savings = monthly_take_home * 0.20
      annual_savings = monthly_savings * 12

      # Project retirement savings (30 years at 7% return)
      retirement_projection =
        annual_savings + NumberF.compound_interest(annual_savings, 0.07, 30, 1)

      # Format all amounts
      formatted_salary = NumberF.currency(annual_salary, "USD")
      formatted_take_home = NumberF.currency(monthly_take_home, "USD")
      formatted_retirement = NumberF.currency(retirement_projection, "USD")

      # Convert retirement projection to words
      retirement_words = NumberF.to_words(retirement_projection, "Dollars", "Cents")

      # Assertions
      assert federal_tax.tax > 0
      assert monthly_take_home < monthly_salary
      # Should be more due to compound interest
      assert retirement_projection > annual_savings * 30
      assert String.contains?(formatted_retirement, "USD")
      assert String.contains?(retirement_words, "Dollars")
    end

    test "scientific measurement conversion scenario" do
      # Laboratory measurements needing unit conversions
      temperature_celsius = 25.0
      distance_kilometers = 100.0
      weight_kilograms = 50.0

      # Convert to imperial units
      temperature_fahrenheit = NumberF.celsius_to_fahrenheit(temperature_celsius)
      distance_miles = NumberF.km_to_miles(distance_kilometers)
      weight_pounds = NumberF.kg_to_pounds(weight_kilograms)

      # Perform calculations with converted values
      # Assuming 2-hour journey
      speed_mph = distance_miles / 2.0

      # Calculate statistics on multiple measurements
      temperature_readings = [23.5, 24.0, 25.0, 25.5, 26.0]
      temp_mean = NumberF.mean(temperature_readings)
      temp_std_dev = NumberF.standard_deviation(temperature_readings)

      # Format for scientific reporting
      formatted_temp_c = NumberF.round_with_precision(temp_mean, 1)
      formatted_temp_f = NumberF.round_with_precision(NumberF.celsius_to_fahrenheit(temp_mean), 1)
      formatted_std_dev = NumberF.round_with_precision(temp_std_dev, 2)

      # Assertions
      assert_in_delta temperature_fahrenheit, 77.0, 0.1
      assert_in_delta distance_miles, 62.14, 0.1
      assert_in_delta weight_pounds, 110.23, 0.1
      assert temp_mean == 24.8
      assert formatted_std_dev == 0.92
    end
  end
end

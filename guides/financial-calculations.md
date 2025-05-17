# Financial Calculations with NumberF

This guide explains how to use NumberF for financial calculations in your Elixir applications. From basic interest calculations to complex loan amortization, NumberF provides the tools you need for finance-related software.

## Basic Interest Calculations

### Simple Interest

Simple interest is calculated on the principal amount only:

```elixir
# Calculate simple interest (principal, rate, time in years)
NumberF.simple_interest(1000, 0.05, 2)  # => 100.0
# $1000 at 5% for 2 years = $100 interest

# For larger amounts
NumberF.simple_interest(50000, 0.03, 5)  # => 7500.0
# $50,000 at 3% for 5 years = $7,500 interest
```

### Compound Interest

Compound interest is calculated on both the principal and the accumulated interest:

```elixir
# Annual compounding (default)
NumberF.compound_interest(1000, 0.05, 2)  # => 102.5
# $1000 at 5% for 2 years with annual compounding = $102.50 interest

# Monthly compounding (frequency = 12)
NumberF.compound_interest(1000, 0.05, 2, 12)  # => 104.94
# $1000 at 5% for 2 years with monthly compounding = $104.94 interest

# Quarterly compounding (frequency = 4)
NumberF.compound_interest(10000, 0.04, 10, 4)  # => 4889.32
# $10,000 at 4% for 10 years with quarterly compounding = $4,889.32 interest
```

## Loan Calculations

### Monthly Installment (EMI)

Calculate the Equated Monthly Installment for a loan:

```elixir
# Calculate EMI (principal, annual rate, term in months)
NumberF.calculate_emi(100000, 0.10, 12)  # => 8791.59
# $100,000 loan at 10% annual interest for 12 months = $8,791.59 monthly payment

# Home loan example
NumberF.calculate_emi(250000, 0.045, 360)  # => 1266.71
# $250,000 mortgage at 4.5% for 30 years (360 months) = $1,266.71 monthly payment
```

## Tax Calculations

### Value Added Tax (VAT)

```elixir
# Calculate VAT (amount, rate)
NumberF.calculate_vat(100, 0.2)  
# => %{net: 100.0, vat: 20.0, gross: 120.0}

# Calculate VAT from inclusive amount
NumberF.calculate_vat(120, 0.2, true)  
# => %{net: 100.0, vat: 20.0, gross: 120.0}
```

### Sales Tax

```elixir
# Calculate sales tax (amount, rate)
NumberF.calculate_sales_tax(100, 0.06)  
# => %{subtotal: 100.0, tax: 6.0, total: 106.0}

# With custom rounding
NumberF.calculate_sales_tax(100, 0.0625, round_to: 0.05)  
# => %{subtotal: 100.0, tax: 6.25, total: 106.25}
```

### Income Tax

```elixir
# UK tax brackets example
brackets = [{0, 0.0}, {12570, 0.2}, {50270, 0.4}, {150000, 0.45}]

# Calculate income tax
NumberF.Tax.calculate_income_tax(30000, brackets)  
# => %{tax: 3486.0, effective_rate: 0.1162}
# £30,000 salary results in £3,486 tax (11.62% effective rate)
```

## Currency Conversion

Convert amounts between currencies:

```elixir
# Basic conversion (amount, from_rate, to_rate)
NumberF.convert_currency(100, 1, 0.85)  # => 85.0
# $100 USD converted to EUR at 0.85 EUR/USD rate

# Multi-currency calculation
amount_usd = 1000
usd_to_eur_rate = 0.92
usd_to_gbp_rate = 0.79

amount_eur = NumberF.convert_currency(amount_usd, 1, usd_to_eur_rate)  # => 920.0
amount_gbp = NumberF.convert_currency(amount_usd, 1, usd_to_gbp_rate)  # => 790.0
```

## Investment Analysis

Combining various functions for investment analysis:

```elixir
# Investment growth projection
initial_investment = 10000
annual_rate = 0.07
years = 30
compounding_frequency = 12

final_value = initial_investment + NumberF.compound_interest(
  initial_investment, 
  annual_rate, 
  years, 
  compounding_frequency
)

formatted_result = NumberF.currency(final_value, "$")
# => "$ 76,122.51" after 30 years

# Calculate effective annual rate with monthly compounding
effective_rate = (1 + annual_rate/12) ** 12 - 1
annual_percentage = NumberF.percentage(effective_rate, 1, 2)
# => 7.23%
```

## Loan Amortization Table

Example of creating a loan amortization schedule using NumberF:

```elixir
defmodule LoanCalculator do
  def generate_amortization_schedule(principal, annual_rate, term_months) do
    # Calculate monthly payment
    monthly_payment = NumberF.calculate_emi(principal, annual_rate, term_months)
    
    # Generate schedule
    monthly_rate = annual_rate / 12
    
    Enum.reduce(1..term_months, {principal, []}, fn month, {remaining_principal, acc} ->
      # Calculate interest for this period
      interest_payment = remaining_principal * monthly_rate
      
      # Calculate principal for this period
      principal_payment = monthly_payment - interest_payment
      
      # Calculate new remaining principal
      new_remaining = remaining_principal - principal_payment
      
      # Create payment record
      payment = %{
        month: month,
        payment: NumberF.round_with_precision(monthly_payment, 2),
        principal: NumberF.round_with_precision(principal_payment, 2),
        interest: NumberF.round_with_precision(interest_payment, 2),
        remaining: max(0, NumberF.round_with_precision(new_remaining, 2))
      }
      
      # Add to accumulator and continue
      {new_remaining, [payment | acc]}
    end)
    |> elem(1)
    |> Enum.reverse()
  end
  
  def print_amortization_schedule(schedule) do
    IO.puts "Month | Payment | Principal | Interest | Remaining"
    IO.puts "------|---------|-----------|----------|----------"
    
    Enum.each(schedule, fn %{month: month, payment: payment, principal: principal,
                             interest: interest, remaining: remaining} ->
      IO.puts "#{String.pad_leading("#{month}", 5)} | #{NumberF.currency(payment, "$", 2)} | " <>
              "#{NumberF.currency(principal, "$", 2)} | " <>
              "#{NumberF.currency(interest, "$", 2)} | " <>
              "#{NumberF.currency(remaining, "$", 2)}"
    end)
  end
end

# Example usage:
schedule = LoanCalculator.generate_amortization_schedule(10000, 0.06, 12)
LoanCalculator.print_amortization_schedule(schedule)
```

## Real Estate Financial Analysis

Example of real estate investment analysis:

```elixir
defmodule RealEstateAnalysis do
  def calculate_roi(purchase_price, closing_costs, repair_costs, annual_rental_income, 
                    annual_expenses, years_held, estimated_sale_price) do
    # Total investment
    total_investment = purchase_price + closing_costs + repair_costs
    
    # Annual cash flow
    annual_cash_flow = annual_rental_income - annual_expenses
    
    # Total cash flow over holding period
    total_cash_flow = annual_cash_flow * years_held
    
    # Profit from sale (simplified, not accounting for taxes)
    sale_profit = estimated_sale_price - purchase_price
    
    # Total profit
    total_profit = total_cash_flow + sale_profit
    
    # Calculate ROI
    roi = NumberF.percentage(total_profit, total_investment, 2)
    
    # Calculate annual ROI
    annual_roi = NumberF.percentage(total_profit / years_held, total_investment, 2)
    
    # Return analysis
    %{
      total_investment: NumberF.currency(total_investment, "$"),
      total_cash_flow: NumberF.currency(total_cash_flow, "$"),
      sale_profit: NumberF.currency(sale_profit, "$"),
      total_profit: NumberF.currency(total_profit, "$"),
      roi: "#{roi}%",
      annual_roi: "#{annual_roi}%"
    }
  end
end

# Example usage:
analysis = RealEstateAnalysis.calculate_roi(
  200000,    # Purchase price
  5000,      # Closing costs
  15000,     # Repair costs
  24000,     # Annual rental income
  10000,     # Annual expenses
  5,         # Years held
  250000     # Estimated sale price
)

# Result would show total ROI and annualized ROI for the investment
```

## Best Practices for Financial Calculations

1. **Use appropriate precision** - Financial calculations often require specific rounding rules
2. **Be careful with floating point** - Use `NumberF.round_with_precision/2` to handle precision issues
3. **Document your assumptions** - Financial formulas often make assumptions about compounding periods, etc.
4. **Validate input data** - Financial calculations are sensitive to incorrect inputs
5. **Use explicit parameter names** - Makes your code more readable and less error-prone

NumberF provides a solid foundation for financial calculations in Elixir applications, from simple interest to complex investment analysis. By combining these tools with Elixir's excellent pattern matching and functional programming features, you can build robust financial software with clear, maintainable code.
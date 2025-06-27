defmodule NumberF.Tax do
  @moduledoc """
  Functions for tax calculations including VAT, sales tax, and income tax.
  """

  @doc """
  Calculates Value Added Tax (VAT) for a given amount and rate.

  ## Parameters
    - `amount`: The amount before tax
    - `rate`: The VAT rate as a decimal (e.g., 0.2 for 20%)
    - `included`: Whether the amount already includes VAT (default: false)

  ## Examples

      iex> NumberF.Tax.calculate_vat(100, 0.2)
      %{net: 100.0, vat: 20.0, gross: 120.0}

      iex> NumberF.Tax.calculate_vat(120, 0.2, true)
      %{net: 100.0, vat: 20.0, gross: 120.0}
  """
  def calculate_vat(amount, rate, included \\ false) when is_number(amount) and is_number(rate) do
    if included do
      # Extract VAT from inclusive amount
      net = amount / (1 + rate)
      vat = amount - net

      %{
        net: Float.round(net, 2),
        vat: Float.round(vat, 2),
        gross: amount * 1.0
      }
    else
      # Add VAT to exclusive amount
      vat = amount * rate
      gross = amount + vat

      %{
        net: amount * 1.0,
        vat: Float.round(vat, 2),
        gross: Float.round(gross, 2)
      }
    end
  end

  @doc """
  Calculates sales tax for a given amount and rate.

  ## Parameters
    - `amount`: The amount before tax
    - `rate`: The sales tax rate as a decimal (e.g., 0.06 for 6%)
    - `options`: Additional options
      - `:round_to`: Round the tax amount to the nearest value (default: 0.01)

  ## Examples

      iex> NumberF.Tax.calculate_sales_tax(100, 0.06)
      %{subtotal: 100.0, tax: 6.0, total: 106.0}

      iex> NumberF.Tax.calculate_sales_tax(100, 0.06, round_to: 0.05)
      %{subtotal: 100.0, tax: 6.0, total: 106.0}
  """
  def calculate_sales_tax(amount, rate, options \\ [])
      when is_number(amount) and is_number(rate) do
    round_to = Keyword.get(options, :round_to, 0.01)

    # Calculate tax
    tax = amount * rate

    # Round tax if needed
    rounded_tax =
      if round_to != 0.01 do
        NumberF.round_to_nearest(tax, round_to)
      else
        Float.round(tax, 2)
      end

    total = amount + rounded_tax

    %{
      subtotal: amount * 1.0,
      tax: rounded_tax,
      total: Float.round(total, 2)
    }
  end

  @doc """
  Calculates progressive income tax based on tax brackets.

  ## Parameters
    - `income`: The taxable income
    - `brackets`: A list of tax brackets, each as a tuple {threshold, rate}
                 sorted in ascending order by threshold

  ## Examples

      iex> brackets = [{0, 0.0}, {12570, 0.2}, {50270, 0.4}, {150000, 0.45}]
      iex> NumberF.Tax.calculate_income_tax(30000, brackets)
      %{tax: 3486.0, effective_rate: 0.1162}
  """
  def calculate_income_tax(income, brackets) when is_number(income) and income >= 0 do
    # Sort brackets by threshold ascending
    sorted_brackets = Enum.sort_by(brackets, fn {threshold, _rate} -> threshold end)

    # Calculate tax for each bracket
    {tax, _} =
      Enum.reduce(sorted_brackets, {0, income}, fn
        # Last bracket or if income is already fully taxed
        {_threshold, _rate}, {acc_tax, remaining} when remaining <= 0 ->
          {acc_tax, 0}

        {threshold, rate}, {acc_tax, remaining} ->
          # Get the next threshold (or income if it's the last bracket)
          next_threshold =
            case Enum.find(sorted_brackets, fn {t, _} -> t > threshold end) do
              # No more brackets, use full income
              nil -> income
              {next_t, _} -> next_t
            end

          # Calculate taxable amount in this bracket
          taxable_in_bracket =
            min(
              remaining,
              max(0, next_threshold - threshold)
            )

          # Add tax for this bracket
          bracket_tax = taxable_in_bracket * rate

          # Update accumulators
          {acc_tax + bracket_tax, remaining - taxable_in_bracket}
      end)

    # Calculate effective tax rate
    effective_rate = if income > 0, do: tax / income, else: 0.0

    %{
      tax: Float.round(tax, 2),
      effective_rate: Float.round(effective_rate, 4)
    }
  end

  @doc """
  Returns common VAT rates for different countries.

  ## Examples

      iex> NumberF.Tax.vat_rates()["UK"]
      0.2

      iex> NumberF.Tax.vat_rates()["Germany"]
      0.19
  """
  def vat_rates do
    %{
      "UK" => 0.2,
      "Ireland" => 0.23,
      "Germany" => 0.19,
      "France" => 0.2,
      "Italy" => 0.22,
      "Spain" => 0.21,
      "Netherlands" => 0.21,
      "Belgium" => 0.21,
      "Sweden" => 0.25,
      "Denmark" => 0.25,
      "Austria" => 0.2,
      "Finland" => 0.24,
      "Greece" => 0.24,
      "Portugal" => 0.23,
      "Luxembourg" => 0.17,
      "Zambia" => 0.16,
      "South Africa" => 0.15,
      "Australia" => 0.1,
      "Japan" => 0.1,
      # Federal GST, provinces have additional rates
      "Canada" => 0.05,
      "Singapore" => 0.08,
      "Switzerland" => 0.077
    }
  end

  @doc """
  Returns sample income tax brackets for different countries.
  Note: These are simplified examples and may not reflect current tax law.

  ## Examples

      iex> NumberF.Tax.income_tax_brackets()["US"]
      [{0, 0.1}, {9950, 0.12}, {40525, 0.22}, {86375, 0.24}, {164925, 0.32}, {209425, 0.35}, {523600, 0.37}]
  """
  def income_tax_brackets do
    %{
      "UK" => [
        # Personal allowance
        {0, 0.0},
        # Basic rate
        {12570, 0.2},
        # Higher rate
        {50270, 0.4},
        # Additional rate
        {150_000, 0.45}
      ],
      "US" => [
        # 10% bracket
        {0, 0.1},
        # 12% bracket
        {9950, 0.12},
        # 22% bracket
        {40525, 0.22},
        # 24% bracket
        {86375, 0.24},
        # 32% bracket
        {164_925, 0.32},
        # 35% bracket
        {209_425, 0.35},
        # 37% bracket
        {523_600, 0.37}
      ],
      "Zambia" => [
        # Tax-free threshold
        {0, 0.0},
        # First band
        {54000, 0.25},
        # Second band
        {84000, 0.3},
        # Third band
        {96000, 0.375}
      ],
      "Germany" => [
        # Tax-free threshold
        {0, 0.0},
        # First bracket
        {9744, 0.14},
        # Second bracket
        {57918, 0.42},
        # Third bracket
        {274_613, 0.45}
      ]
    }
  end

  @doc """
  Calculates withholding tax for dividends or interest based on a flat rate.

  ## Parameters
    - `amount`: The gross amount
    - `rate`: The withholding tax rate as a decimal

  ## Examples

      iex> NumberF.Tax.calculate_withholding_tax(1000, 0.15)
      %{gross: 1000.0, tax: 150.0, net: 850.0}
  """
  def calculate_withholding_tax(amount, rate) when is_number(amount) and is_number(rate) do
    tax = amount * rate
    net = amount - tax

    %{
      gross: amount * 1.0,
      tax: Float.round(tax, 2),
      net: Float.round(net, 2)
    }
  end

  @doc """
  Calculates corporate tax on profits.

  ## Parameters
    - `profit`: The taxable profit
    - `rate`: The corporate tax rate as a decimal

  ## Examples

      iex> NumberF.Tax.calculate_corporate_tax(100000, 0.19)
      %{profit: 100000.0, tax: 19000.0, after_tax: 81000.0}
  """
  def calculate_corporate_tax(profit, rate) when is_number(profit) and is_number(rate) do
    tax = profit * rate
    after_tax = profit - tax

    %{
      profit: profit * 1.0,
      tax: Float.round(tax, 2),
      after_tax: Float.round(after_tax, 2)
    }
  end

  @doc """
  Calculates tax on capital gains, with optional annual exemption.

  ## Parameters
    - `gain`: The capital gain amount
    - `rate`: The capital gains tax rate as a decimal
    - `exemption`: Annual tax-free allowance (default: 0)

  ## Examples

      iex> NumberF.Tax.calculate_capital_gains_tax(20000, 0.2, 12300)
      %{gain: 20000.0, taxable_gain: 7700.0, tax: 1540.0, net: 18460.0}
  """
  def calculate_capital_gains_tax(gain, rate, exemption \\ 0)
      when is_number(gain) and is_number(rate) and is_number(exemption) do
    # Apply exemption
    taxable_gain = max(0, gain - exemption)

    # Calculate tax
    tax = taxable_gain * rate

    # Calculate net amount
    net = gain - tax

    %{
      gain: gain * 1.0,
      taxable_gain: taxable_gain * 1.0,
      tax: Float.round(tax, 2),
      net: Float.round(net, 2)
    }
  end

  @doc """
  Calculates payroll taxes including employee and employer contributions.

  ## Parameters
    - `salary`: The gross salary
    - `employee_rate`: The employee contribution rate as a decimal
    - `employer_rate`: The employer contribution rate as a decimal
    - `cap`: Maximum amount subject to payroll tax (default: nil, no cap)

  ## Examples

      iex> NumberF.Tax.calculate_payroll_tax(50000, 0.12, 0.138)
      %{salary: 50000.0, employee_contribution: 6000.0, employer_contribution: 6900.0, total_cost: 56900.0, take_home: 44000.0}
  """
  def calculate_payroll_tax(salary, employee_rate, employer_rate, cap \\ nil)
      when is_number(salary) and is_number(employee_rate) and is_number(employer_rate) do
    # Apply cap if provided
    taxable_amount = if cap && salary > cap, do: cap, else: salary

    # Calculate contributions
    employee_contribution = taxable_amount * employee_rate
    employer_contribution = taxable_amount * employer_rate

    # Calculate totals
    total_cost = salary + employer_contribution
    take_home = salary - employee_contribution

    %{
      salary: salary * 1.0,
      employee_contribution: Float.round(employee_contribution, 2),
      employer_contribution: Float.round(employer_contribution, 2),
      total_cost: Float.round(total_cost, 2),
      take_home: Float.round(take_home, 2)
    }
  end
end

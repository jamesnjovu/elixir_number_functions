defmodule NumberF.Financial do
  @moduledoc """
  Functions for financial calculations such as interest, EMI, and currency conversion.
  """

  @doc """
  Calculates simple interest.
  """
  def simple_interest(principal, rate, time) do
    result = principal * rate * time
    Float.round(result, 2)
  end

  @doc """
  Calculates compound interest.
  """
  def compound_interest(principal, rate, time, frequency) do
    result = principal * :math.pow(1 + rate / frequency, frequency * time) - principal
    Float.round(result, 2)
  end

  @doc """
  Calculates EMI (Equated Monthly Installment).
  """
  def calculate_emi(principal, rate, term_months) do
    monthly_rate = rate / 12

    # Use more precise calculation
    power_term = :math.pow(1 + monthly_rate, term_months)
    emi = principal * monthly_rate * power_term / (power_term - 1)

    # Round to match expected precision
    Float.round(emi, 2)
  end

  @doc """
  Converts currency based on exchange rates.
  """
  def convert_currency(amount, from_rate, to_rate) do
    result = amount * to_rate / from_rate
    Float.round(result, 2)
  end
end

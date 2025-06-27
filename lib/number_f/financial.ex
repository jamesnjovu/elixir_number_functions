defmodule NumberF.Financial do
  @moduledoc """
  Functions for financial calculations such as interest, EMI, and currency conversion.
  """

  @doc """
  Calculates simple interest.
  """
  def simple_interest(principal, rate, time) do
    principal * rate * time
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

    emi =
      principal * monthly_rate * :math.pow(1 + monthly_rate, term_months) /
        (:math.pow(1 + monthly_rate, term_months) - 1)

    Float.round(emi, 2)
  end

  @doc """
  Converts currency based on exchange rates.
  """
  def convert_currency(amount, from_rate, to_rate) do
    amount * to_rate / from_rate
  end
end

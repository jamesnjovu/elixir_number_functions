defmodule NumberF.Financial do
  @moduledoc """
  Functions for financial calculations such as interest, EMI, and currency conversion.
  """

  @doc """
  Calculates simple interest.
  """
  def simple_interest(principal, rate, time)
      when is_number(principal) and is_number(rate) and is_number(time) and time >= 0 do
    Float.round(principal * rate * time, 2)
  end

  def simple_interest(principal, rate, time)
      when is_number(principal) and is_number(rate) and is_number(time) and time < 0 do
    raise ArgumentError, "time period cannot be negative, got: #{inspect(time)}"
  end

  def simple_interest(principal, rate, time) do
    raise ArgumentError,
          "simple_interest expects numbers, got: " <>
            "principal=#{inspect(principal)}, rate=#{inspect(rate)}, time=#{inspect(time)}"
  end

  @doc """
  Calculates compound interest.
  """
  def compound_interest(principal, rate, time, frequency)
      when is_number(principal) and is_number(rate) and is_number(time) and
             is_number(frequency) and frequency != 0 do
    Float.round(principal * :math.pow(1 + rate / frequency, frequency * time) - principal, 2)
  end

  def compound_interest(principal, rate, time, frequency) do
    raise ArgumentError,
          "compound_interest expects numbers with a non-zero frequency, got: " <>
            "principal=#{inspect(principal)}, rate=#{inspect(rate)}, " <>
            "time=#{inspect(time)}, frequency=#{inspect(frequency)}"
  end

  @doc """
  Calculates EMI (Equated Monthly Installment).
  """
  def calculate_emi(principal, rate, term_months)
      when is_number(principal) and is_number(rate) and is_number(term_months) and
             term_months > 0 do
    monthly_rate = rate / 12

    # An interest-free loan is a real product, and the standard annuity formula is
    # undefined for it: with rate 0 both the numerator and `power_term - 1` are 0,
    # so the general branch raised ArithmeticError. The limit as r approaches 0 is
    # simply the principal spread evenly across the term.
    emi =
      if monthly_rate == 0 do
        principal / term_months
      else
        power_term = :math.pow(1 + monthly_rate, term_months)
        principal * monthly_rate * power_term / (power_term - 1)
      end

    Float.round(emi, 2)
  end

  def calculate_emi(principal, rate, term_months) do
    raise ArgumentError,
          "calculate_emi expects numbers with term_months > 0, got: " <>
            "principal=#{inspect(principal)}, rate=#{inspect(rate)}, " <>
            "term_months=#{inspect(term_months)}"
  end

  @doc """
  Converts currency based on exchange rates.
  """
  def convert_currency(amount, from_rate, to_rate)
      when is_number(amount) and is_number(from_rate) and is_number(to_rate) and
             from_rate > 0 and to_rate > 0 do
    Float.round(amount * to_rate / from_rate, 2)
  end

  def convert_currency(amount, from_rate, to_rate) do
    raise ArgumentError,
          "convert_currency expects numbers with positive rates, got: " <>
            "amount=#{inspect(amount)}, from_rate=#{inspect(from_rate)}, to_rate=#{inspect(to_rate)}"
  end
end

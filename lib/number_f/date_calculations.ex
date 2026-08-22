defmodule NumberF.DateCalculations do
  @moduledoc """
  Functions for performing date-based calculations.
  """

  @doc """
  Calculates age based on birth date.
  """
  def calculate_age(birth_date) do
    today = Date.utc_today()
    years = today.year - birth_date.year

    # Adjust if birthday hasn't occurred yet this year
    if Date.compare(
         %{today | year: today.year - years},
         birth_date
       ) == :lt do
      years - 1
    else
      years
    end
  end

  @doc """
  Calculates payment due date based on invoice date and terms.
  """
  def payment_due_date(invoice_date, terms_days) do
    Date.add(invoice_date, terms_days)
  end

  @doc """
  Calculates the number of days between two dates.
  """
  def days_between(date1, date2) do
    Date.diff(date2, date1)
  end

  @doc """
  Calculates the number of business days between two dates.
  """
  def business_days_between(date1, date2) do
    # Normalise the order and re-apply the sign at the end. Passing a reversed pair
    # used to build a descending range (`0..-4`), which emits a Range deprecation
    # warning at runtime and counted upward anyway, returning 4 rather than -4.
    sign = if Date.compare(date1, date2) == :gt, do: -1, else: 1
    {from, to} = Enum.min_max_by([date1, date2], &Date.to_erl/1)

    count =
      from
      |> Date.range(to)
      |> Enum.count(&is_business_day?/1)

    sign * count
  end

  @doc """
  Calculates the date after adding a specified number of business days.
  """
  def add_business_days(date, num_days) when is_integer(num_days) do
    # A negative offset is a legitimate question ("three business days before the
    # invoice date"), and the old `num_days >= 0` guard raised FunctionClauseError
    # on it. Walk one day at a time in whichever direction is asked for.
    step = if num_days < 0, do: -1, else: 1
    add_business_days_recursively(date, abs(num_days), step)
  end

  defp add_business_days_recursively(date, 0, _step), do: date

  defp add_business_days_recursively(date, days_left, step) do
    next_date = Date.add(date, step)
    remaining = if is_business_day?(next_date), do: days_left - 1, else: days_left

    add_business_days_recursively(next_date, remaining, step)
  end

  @doc """
  Determines if a date is a business day.
  """
  def is_business_day?(date) do
    day_of_week = Date.day_of_week(date)
    # Not Saturday or Sunday
    day_of_week != 6 and day_of_week != 7
  end

  @doc """
  Calculates the next business day after the given date.
  """
  def next_business_day(date) do
    next_date = Date.add(date, 1)

    if is_business_day?(next_date) do
      next_date
    else
      next_business_day(next_date)
    end
  end
end

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
    days = days_between(date1, date2)

    # Generate list of all dates in range
    dates = for n <- 0..days, do: Date.add(date1, n)

    # Count days that are not weekends
    Enum.count(dates, fn date ->
      day_of_week = Date.day_of_week(date)
      day_of_week != 6 and day_of_week != 7  # Not Saturday or Sunday
    end)
  end

  @doc """
  Calculates the date after adding a specified number of business days.
  """
  def add_business_days(date, num_days) when is_integer(num_days) and num_days >= 0 do
    add_business_days_recursively(date, num_days)
  end

  defp add_business_days_recursively(date, 0), do: date
  defp add_business_days_recursively(date, days_left) do
    next_date = Date.add(date, 1)
    day_of_week = Date.day_of_week(next_date)

    if day_of_week != 6 and day_of_week != 7 do
      # This is a business day, count it
      add_business_days_recursively(next_date, days_left - 1)
    else
      # This is a weekend, don't count it
      add_business_days_recursively(next_date, days_left)
    end
  end

  @doc """
  Determines if a date is a business day.
  """
  def is_business_day?(date) do
    day_of_week = Date.day_of_week(date)
    day_of_week != 6 and day_of_week != 7  # Not Saturday or Sunday
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

defmodule NumberF.DateCalculations do
  @moduledoc """
  Functions for performing date-based calculations.
  """

  @doc """
  Calculates age based on birth date.
  """
  def calculate_age(%Date{} = birth_date) do
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

  def calculate_age(birth_date) do
    raise ArgumentError, "calculate_age expects a Date, got: #{inspect(birth_date)}"
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

  @doc """
  Calendar quarter of a date, 1 to 4.

  ## Examples

      iex> NumberF.DateCalculations.quarter(~D[2024-08-22])
      3
  """
  def quarter(%Date{month: month}), do: div(month - 1, 3) + 1

  @doc """
  First day of the date's calendar quarter.

  ## Examples

      iex> NumberF.DateCalculations.quarter_start(~D[2024-08-22])
      ~D[2024-07-01]
  """
  def quarter_start(%Date{year: year} = date) do
    Date.new!(year, (quarter(date) - 1) * 3 + 1, 1)
  end

  @doc """
  Last day of the date's calendar quarter.

  ## Examples

      iex> NumberF.DateCalculations.quarter_end(~D[2024-08-22])
      ~D[2024-09-30]
  """
  def quarter_end(%Date{year: year} = date) do
    month = quarter(date) * 3
    Date.new!(year, month, days_in_month(year, month))
  end

  @doc """
  Fiscal year containing the date, given the month the fiscal year starts in.

  The year returned is the one the fiscal year *ends* in, which is the common
  convention: with an April start, 2024-08-22 falls in FY2025.

  ## Examples

      iex> NumberF.DateCalculations.fiscal_year(~D[2024-08-22], 4)
      2025

      iex> NumberF.DateCalculations.fiscal_year(~D[2024-02-10], 4)
      2024
  """
  def fiscal_year(%Date{year: year, month: month}, start_month \\ 4)
      when is_integer(start_month) and start_month in 1..12 do
    if month >= start_month, do: year + 1, else: year
  end

  @doc """
  Number of days in a given month.

  ## Examples

      iex> NumberF.DateCalculations.days_in_month(2024, 2)
      29

      iex> NumberF.DateCalculations.days_in_month(2023, 2)
      28
  """
  def days_in_month(year, month) when is_integer(year) and is_integer(month) and month in 1..12 do
    :calendar.last_day_of_the_month(year, month)
  end

  @doc """
  Whether a year is a leap year in the proleptic Gregorian calendar.

  ## Examples

      iex> NumberF.DateCalculations.leap_year?(2024)
      true

      iex> NumberF.DateCalculations.leap_year?(1900)
      false
  """
  def leap_year?(year) when is_integer(year), do: :calendar.is_leap_year(year)

  @doc """
  ISO-8601 week number.

  ## Edge cases

  ISO weeks belong to the year containing their Thursday, so the first days of
  January can fall in week 52 or 53 of the previous year.

  ## Examples

      iex> NumberF.DateCalculations.week_number(~D[2024-08-22])
      34
  """
  def week_number(%Date{} = date) do
    {_year, week} = date |> Date.to_erl() |> :calendar.iso_week_number()
    week
  end

  @doc """
  First day of the date's month.

  ## Examples

      iex> NumberF.DateCalculations.month_start(~D[2024-08-22])
      ~D[2024-08-01]
  """
  def month_start(%Date{year: year, month: month}), do: Date.new!(year, month, 1)

  @doc """
  Last day of the date's month.

  ## Examples

      iex> NumberF.DateCalculations.month_end(~D[2024-02-10])
      ~D[2024-02-29]
  """
  def month_end(%Date{year: year, month: month}),
    do: Date.new!(year, month, days_in_month(year, month))

  @doc """
  Age in whole months.

  ## Examples

      iex> NumberF.DateCalculations.age_in_months(~D[2020-01-15], ~D[2024-08-22])
      55
  """
  def age_in_months(%Date{} = birth_date, %Date{} = as_of \\ Date.utc_today()) do
    months = (as_of.year - birth_date.year) * 12 + (as_of.month - birth_date.month)

    if as_of.day < birth_date.day, do: months - 1, else: months
  end
end

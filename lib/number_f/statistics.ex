defmodule NumberF.Statistics do
  @moduledoc """
  Functions for statistical calculations and analysis of numerical data.
  """

  @doc """
  Calculates the arithmetic mean of a list of numbers.
  """
  def mean([]), do: nil

  def mean(numbers) when is_list(numbers) do
    # Validated rather than left to Enum.sum/1: a stray nil in the list otherwise
    # surfaces as an ArithmeticError from deep inside Enum, naming neither the
    # function the caller invoked nor the value that was wrong.
    if Enum.any?(numbers, &(not is_number(&1))) do
      raise ArgumentError, "mean/1 expects a list of numbers, found a non-numeric value"
    end

    Enum.sum(numbers) / length(numbers)
  end

  def mean(other), do: raise(ArgumentError, "mean/1 expects a list, got: #{inspect(other)}")

  @doc """
  Finds the median value from a list of numbers.
  """
  def median([]), do: nil

  def median(numbers) when is_list(numbers) do
    sorted = Enum.sort(numbers)
    count = length(sorted)

    if rem(count, 2) == 0 do
      # Even number of elements
      middle_idx = div(count, 2)
      (Enum.at(sorted, middle_idx - 1) + Enum.at(sorted, middle_idx)) / 2
    else
      # Odd number of elements
      Enum.at(sorted, div(count, 2))
    end
  end

  def median(other), do: raise(ArgumentError, "median/1 expects a list, got: #{inspect(other)}")

  @doc """
  Finds the most frequently occurring value(s) in a list.
  """
  def mode([]), do: []

  def mode(numbers) when is_list(numbers) do
    frequencies =
      Enum.reduce(numbers, %{}, fn num, acc ->
        Map.update(acc, num, 1, &(&1 + 1))
      end)

    {_value, max_freq} = Enum.max_by(frequencies, fn {_value, count} -> count end)

    frequencies
    |> Enum.filter(fn {_value, count} -> count == max_freq end)
    |> Enum.map(fn {value, _count} -> value end)
    |> Enum.sort()
  end

  def mode(other), do: raise(ArgumentError, "mode/1 expects a list, got: #{inspect(other)}")

  @doc """
  Calculates the **population** standard deviation of a dataset (divides by N).

  ## Precision

  This is the population form. If your list is a *sample* drawn from a larger
  population — which is the more common case — use `sample_standard_deviation/1`,
  which applies Bessel's correction (divides by N-1). The two differ by a factor of
  `sqrt(N/(N-1))`, so they converge as the dataset grows but diverge sharply for
  small lists.

  ## Examples

      iex> NumberF.Statistics.standard_deviation([2, 4, 4, 4, 5, 5, 7, 9])
      2.0
  """
  def standard_deviation([]), do: nil
  def standard_deviation([_single]), do: 0.0
  def standard_deviation(numbers), do: numbers |> variance() |> :math.sqrt()

  @doc """
  Calculates the **sample** standard deviation of a dataset (divides by N-1).

  Use this when the list is a sample rather than the whole population. See
  `standard_deviation/1` for the population form.

  ## Examples

      iex> NumberF.Statistics.sample_standard_deviation([2, 4, 4, 4, 5, 5, 7, 9])
      2.138089935299395
  """
  def sample_standard_deviation([]), do: nil
  def sample_standard_deviation([_single]), do: 0.0
  def sample_standard_deviation(numbers), do: numbers |> sample_variance() |> :math.sqrt()

  @doc """
  Calculates the **population** variance of a dataset (divides by N).

  ## Precision

  See `standard_deviation/1` — use `sample_variance/1` if the list is a sample.

  ## Examples

      iex> NumberF.Statistics.variance([2, 4, 4, 4, 5, 5, 7, 9])
      4.0
  """
  def variance([]), do: nil
  def variance([_single]), do: 0.0
  def variance(numbers), do: sum_of_squared_deviations(numbers) / length(numbers)

  @doc """
  Calculates the **sample** variance of a dataset (divides by N-1, Bessel's correction).

  ## Examples

      iex> NumberF.Statistics.sample_variance([2, 4, 4, 4, 5, 5, 7, 9])
      4.571428571428571
  """
  def sample_variance([]), do: nil
  def sample_variance([_single]), do: 0.0
  def sample_variance(numbers), do: sum_of_squared_deviations(numbers) / (length(numbers) - 1)

  defp sum_of_squared_deviations(numbers) do
    avg = mean(numbers)
    Enum.reduce(numbers, 0, fn num, sum -> sum + :math.pow(num - avg, 2) end)
  end

  @doc """
  Calculates the range (difference between max and min values).
  """
  def range([]), do: nil
  def range([_single]), do: 0.0

  def range(numbers) when is_list(numbers) do
    (Enum.max(numbers) - Enum.min(numbers)) * 1.0
  end

  def range(other), do: raise(ArgumentError, "range/1 expects a list, got: #{inspect(other)}")
end

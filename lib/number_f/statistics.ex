defmodule NumberF.Statistics do
  @moduledoc """
  Functions for statistical calculations and analysis of numerical data.
  """

  @doc """
  Calculates the arithmetic mean of a list of numbers.
  """
  def mean([]), do: nil

  def mean(numbers) do
    total = Enum.sum(numbers)
    count = length(numbers)
    total / count
  end

  @doc """
  Finds the median value from a list of numbers.
  """
  def median([]), do: nil

  def median(numbers) do
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

  @doc """
  Finds the most frequently occurring value(s) in a list.
  """
  def mode([]), do: []

  def mode(numbers) do
    frequencies =
      Enum.reduce(numbers, %{}, fn num, acc ->
        Map.update(acc, num, 1, &(&1 + 1))
      end)

    {_count, max_freq} = Enum.max_by(frequencies, fn {_num, count} -> count end)

    Enum.filter(frequencies, fn {_num, count} -> count == max_freq end)
    |> Enum.map(fn {num, _count} -> num end)
    |> Enum.sort()
  end

  @doc """
  Calculates standard deviation of a dataset.
  """
  def standard_deviation([]), do: nil
  def standard_deviation([_single]), do: 0.0

  def standard_deviation(numbers) do
    avg = mean(numbers)

    variance =
      Enum.reduce(numbers, 0, fn num, sum ->
        sum + :math.pow(num - avg, 2)
      end) / (length(numbers) - 1)

    :math.sqrt(variance)
  end

  @doc """
  Calculates the variance of a dataset.
  """
  def variance([]), do: nil
  def variance([_single]), do: 0.0

  def variance(numbers) do
    avg = mean(numbers)

    Enum.reduce(numbers, 0, fn num, sum ->
      sum + :math.pow(num - avg, 2)
    end) / (length(numbers) - 1)
  end

  @doc """
  Calculates the range (difference between max and min values).
  """
  def range([]), do: nil
  def range([_single]), do: 0.0

  def range(numbers) do
    Enum.max(numbers) - Enum.min(numbers)
  end
end

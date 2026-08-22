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

  @doc """
  Returns the value at the given percentile using linear interpolation.

  ## Precision

  Uses the linear-interpolation-between-closest-ranks method (the same as NumPy's
  default and R's type 7). Other definitions exist and disagree on small datasets,
  so a percentile from here will not always match one from a spreadsheet.

  ## Examples

      iex> NumberF.Statistics.percentile([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 25)
      3.25

      iex> NumberF.Statistics.percentile([1, 2, 3, 4], 50)
      2.5
  """
  def percentile([], _p), do: nil

  def percentile(numbers, p) when is_list(numbers) and is_number(p) and p >= 0 and p <= 100 do
    sorted = Enum.sort(numbers)
    rank = p / 100 * (length(sorted) - 1)
    lower = trunc(rank)
    upper = min(lower + 1, length(sorted) - 1)
    weight = rank - lower

    Enum.at(sorted, lower) * (1 - weight) + Enum.at(sorted, upper) * weight
  end

  def percentile(_numbers, p) do
    raise ArgumentError, "percentile expects p between 0 and 100, got: #{inspect(p)}"
  end

  @doc """
  Returns the first, second and third quartiles.

  ## Examples

      iex> NumberF.Statistics.quartiles([1, 2, 3, 4, 5, 6, 7, 8])
      %{q1: 2.75, q2: 4.5, q3: 6.25}
  """
  def quartiles([]), do: nil

  def quartiles(numbers) when is_list(numbers) do
    %{
      q1: percentile(numbers, 25),
      q2: percentile(numbers, 50),
      q3: percentile(numbers, 75)
    }
  end

  @doc """
  Returns the interquartile range: the spread of the middle half of the data.

  ## Examples

      iex> NumberF.Statistics.iqr([1, 2, 3, 4, 5, 6, 7, 8])
      3.5
  """
  def iqr([]), do: nil
  def iqr(numbers) when is_list(numbers), do: percentile(numbers, 75) - percentile(numbers, 25)

  @doc """
  Returns how many standard deviations `value` sits from the mean.

  ## Edge cases

  A zero standard deviation raises: every value is identical, so "how many
  deviations away" has no answer rather than an answer of zero.

  ## Examples

      iex> NumberF.Statistics.z_score(6, 4, 2)
      1.0
  """
  def z_score(_value, _mean, 0), do: raise(ArgumentError, "standard deviation cannot be zero")
  def z_score(_value, _mean, +0.0), do: raise(ArgumentError, "standard deviation cannot be zero")

  def z_score(value, mean, stddev)
      when is_number(value) and is_number(mean) and is_number(stddev) do
    (value - mean) / stddev
  end

  @doc """
  Standardises a list to zero mean and unit variance.

  ## Examples

      iex> NumberF.Statistics.z_scores([2, 4, 6])
      [-1.224744871391589, 0.0, 1.224744871391589]
  """
  def z_scores([]), do: []

  def z_scores(numbers) when is_list(numbers) do
    avg = mean(numbers)
    sd = standard_deviation(numbers)

    if sd == 0.0 do
      raise ArgumentError, "cannot standardise a list where every value is identical"
    end

    Enum.map(numbers, &((&1 - avg) / sd))
  end

  @doc """
  Pearson correlation coefficient between two equal-length lists, in -1..1.

  ## Examples

      iex> NumberF.Statistics.correlation([1, 2, 3, 4, 5], [2, 4, 5, 4, 5])
      0.7745966692414833
  """
  def correlation(xs, ys) when is_list(xs) and is_list(ys) and length(xs) == length(ys) do
    sx = standard_deviation(xs)
    sy = standard_deviation(ys)

    if sx == 0.0 or sy == 0.0 do
      raise ArgumentError, "correlation is undefined when either list has zero variance"
    end

    covariance(xs, ys) / (sx * sy)
  end

  def correlation(xs, ys) do
    raise ArgumentError,
          "correlation expects two lists of equal length, got #{length(xs)} and #{length(ys)}"
  end

  @doc """
  Population covariance of two equal-length lists.

  ## Examples

      iex> NumberF.Statistics.covariance([1, 2, 3, 4, 5], [2, 4, 5, 4, 5])
      1.2
  """
  def covariance(xs, ys) when is_list(xs) and is_list(ys) and length(xs) == length(ys) do
    mx = mean(xs)
    my = mean(ys)

    xs
    |> Enum.zip(ys)
    |> Enum.reduce(0, fn {x, y}, acc -> acc + (x - mx) * (y - my) end)
    |> Kernel./(length(xs))
  end

  def covariance(xs, ys) do
    raise ArgumentError,
          "covariance expects two lists of equal length, got #{length(xs)} and #{length(ys)}"
  end

  @doc """
  Least-squares linear regression of `ys` on `xs`.

  Returns the slope, intercept, and the r-squared goodness of fit.

  ## Examples

      iex> NumberF.Statistics.linear_regression([1, 2, 3, 4, 5], [2, 4, 5, 4, 5])
      %{slope: 0.6, intercept: 2.2, r_squared: 0.5999999999999999}
  """
  def linear_regression(xs, ys) when is_list(xs) and is_list(ys) and length(xs) == length(ys) do
    slope = covariance(xs, ys) / variance(xs)
    intercept = mean(ys) - slope * mean(xs)
    r = correlation(xs, ys)

    %{slope: slope, intercept: intercept, r_squared: r * r}
  end

  @doc """
  Mean weighted by a matching list of weights.

  ## Examples

      iex> NumberF.Statistics.weighted_mean([90, 80, 70], [0.5, 0.3, 0.2])
      83.0
  """
  def weighted_mean(values, weights)
      when is_list(values) and is_list(weights) and length(values) == length(weights) do
    total_weight = Enum.sum(weights)

    if total_weight == 0 do
      raise ArgumentError, "weights must not sum to zero"
    end

    values
    |> Enum.zip(weights)
    |> Enum.reduce(0, fn {v, w}, acc -> acc + v * w end)
    |> Kernel./(total_weight)
  end

  def weighted_mean(values, weights) do
    raise ArgumentError,
          "weighted_mean expects lists of equal length, got #{length(values)} and #{length(weights)}"
  end

  @doc """
  Geometric mean — the correct average for growth rates and ratios.

  ## Precision

  Averaging three years of 10%, 5% and 20% growth arithmetically overstates the
  compound result. Pass growth factors (1.10, 1.05, 1.20), not percentages.

  ## Examples

      iex> NumberF.Statistics.geometric_mean([1, 4, 16]) |> Float.round(4)
      4.0
  """
  def geometric_mean([]), do: nil

  def geometric_mean(numbers) when is_list(numbers) do
    if Enum.any?(numbers, &(&1 <= 0)) do
      raise ArgumentError, "geometric_mean requires strictly positive values"
    end

    numbers
    |> Enum.reduce(0.0, fn n, acc -> acc + :math.log(n) end)
    |> Kernel./(length(numbers))
    |> :math.exp()
  end

  @doc """
  Harmonic mean — the correct average for rates over a fixed distance.

  ## Examples

      iex> NumberF.Statistics.harmonic_mean([40, 60]) |> Float.round(6)
      48.0
  """
  def harmonic_mean([]), do: nil

  def harmonic_mean(numbers) when is_list(numbers) do
    if Enum.any?(numbers, &(&1 <= 0)) do
      raise ArgumentError, "harmonic_mean requires strictly positive values"
    end

    length(numbers) / Enum.reduce(numbers, 0.0, fn n, acc -> acc + 1 / n end)
  end

  @doc """
  A one-call description of a dataset.

  ## Examples

      iex> NumberF.Statistics.summary([1, 2, 3, 4, 5])
      %{count: 5, min: 1, q1: 2.0, median: 3, q3: 4.0, max: 5, mean: 3.0,
        stddev: 1.4142135623730951}
  """
  def summary([]), do: nil

  def summary(numbers) when is_list(numbers) do
    %{
      count: length(numbers),
      min: Enum.min(numbers),
      q1: percentile(numbers, 25),
      median: median(numbers),
      q3: percentile(numbers, 75),
      max: Enum.max(numbers),
      mean: mean(numbers),
      stddev: standard_deviation(numbers)
    }
  end

  @doc """
  Simple moving average over a sliding window.

  Returns `length(numbers) - window + 1` values.

  ## Examples

      iex> NumberF.Statistics.moving_average([1, 2, 3, 4, 5], 3)
      [2.0, 3.0, 4.0]
  """
  def moving_average(numbers, window)
      when is_list(numbers) and is_integer(window) and window > 0 do
    if window > length(numbers) do
      raise ArgumentError,
            "window #{window} is larger than the list (#{length(numbers)} items)"
    end

    numbers
    |> Enum.chunk_every(window, 1, :discard)
    |> Enum.map(&mean/1)
  end

  @doc """
  Running total of a list.

  ## Examples

      iex> NumberF.Statistics.cumulative_sum([1, 2, 3, 4])
      [1, 3, 6, 10]
  """
  def cumulative_sum(numbers) when is_list(numbers) do
    numbers
    |> Enum.scan(&(&1 + &2))
  end

  @doc """
  Rescales a list to the 0..1 range (min-max normalisation).

  ## Edge cases

  A list where every value is identical has no range to scale against, so it maps
  to all zeros rather than dividing by zero.

  ## Examples

      iex> NumberF.Statistics.normalize([10, 20, 30])
      [0.0, 0.5, 1.0]
  """
  def normalize([]), do: []

  def normalize(numbers) when is_list(numbers) do
    min = Enum.min(numbers)
    max = Enum.max(numbers)

    if max == min do
      Enum.map(numbers, fn _ -> 0.0 end)
    else
      Enum.map(numbers, &((&1 - min) / (max - min)))
    end
  end

  @doc """
  Values that fall outside the expected spread.

  Options: `method: :iqr` (default, anything beyond 1.5 x IQR from the quartiles)
  or `method: :zscore` (anything more than three standard deviations from the mean).

  ## Examples

      iex> NumberF.Statistics.outliers([1, 2, 3, 4, 100])
      [100]
  """
  def outliers(numbers, options \\ [])
  def outliers([], _options), do: []

  def outliers(numbers, options) when is_list(numbers) do
    case Keyword.get(options, :method, :iqr) do
      :iqr ->
        q1 = percentile(numbers, 25)
        q3 = percentile(numbers, 75)
        fence = 1.5 * (q3 - q1)
        Enum.filter(numbers, &(&1 < q1 - fence or &1 > q3 + fence))

      :zscore ->
        avg = mean(numbers)
        sd = standard_deviation(numbers)
        if sd == 0.0, do: [], else: Enum.filter(numbers, &(abs((&1 - avg) / sd) > 3))

      other ->
        raise ArgumentError, "unknown outlier method: #{inspect(other)}. Use :iqr or :zscore."
    end
  end

  @doc """
  The list with its outliers removed. See `outliers/2` for the options.

  ## Examples

      iex> NumberF.Statistics.remove_outliers([1, 2, 3, 4, 100])
      [1, 2, 3, 4]
  """
  def remove_outliers(numbers, options \\ []) when is_list(numbers) do
    dropped = outliers(numbers, options)
    Enum.reject(numbers, &(&1 in dropped))
  end

  @doc """
  Counts how often each value occurs.

  ## Examples

      iex> NumberF.Statistics.frequency_distribution([1, 2, 2, 3, 3, 3])
      %{1 => 1, 2 => 2, 3 => 3}
  """
  def frequency_distribution(numbers) when is_list(numbers) do
    Enum.frequencies(numbers)
  end

  @doc """
  Mean after discarding a proportion from each end.

  More robust than `mean/1` when the extremes are unreliable.

  ## Examples

      iex> NumberF.Statistics.trimmed_mean([1, 2, 3, 4, 100], 0.2)
      3.0
  """
  def trimmed_mean(numbers, proportion \\ 0.1)
  def trimmed_mean([], _proportion), do: nil

  def trimmed_mean(numbers, proportion)
      when is_list(numbers) and is_number(proportion) and proportion >= 0 and proportion < 0.5 do
    drop = trunc(length(numbers) * proportion)

    numbers
    |> Enum.sort()
    |> Enum.drop(drop)
    |> Enum.drop(-drop)
    |> mean()
  end

  def trimmed_mean(_numbers, proportion) do
    raise ArgumentError,
          "trimmed_mean expects a proportion in 0..0.5 (exclusive), got: #{inspect(proportion)}"
  end

  @doc """
  Standard deviation as a proportion of the mean — a unitless measure of spread.

  Useful for comparing the variability of datasets with different scales or units.

  ## Examples

      iex> NumberF.Statistics.coefficient_of_variation([2, 4, 4, 4, 5, 5, 7, 9])
      0.4
  """
  def coefficient_of_variation([]), do: nil

  def coefficient_of_variation(numbers) when is_list(numbers) do
    avg = mean(numbers)

    if avg == 0.0 do
      raise ArgumentError, "coefficient of variation is undefined for a mean of zero"
    end

    standard_deviation(numbers) / avg
  end
end

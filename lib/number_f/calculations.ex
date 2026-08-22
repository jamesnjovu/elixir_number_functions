defmodule NumberF.Calculations do
  @moduledoc """
  General numeric calculation functions.
  """

  @doc """
  Calculates a percentage with specified precision.
  """
  def percentage(value, total, precision) do
    result = value / total * 100
    Float.round(result, precision)
  end

  @doc """
  Rounds a number to the nearest specified value.
  """
  def round_to_nearest(value, nearest) do
    round(value / nearest) * nearest
  end

  @doc """
  Checks if a number is within a specified range (inclusive).
  """
  def in_range?(value, min, max) when is_number(value) and is_number(min) and is_number(max) do
    value >= min and value <= max
  end

  @doc """
  Performs a linear interpolation between two points.
  """
  def interpolate(x, x0, y0, x1, y1) do
    y0 + (x - x0) * (y1 - y0) / (x1 - x0)
  end

  @doc """
  Calculates the Greatest Common Divisor (GCD) of two integers.
  """
  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  @doc """
  Calculates the Least Common Multiple (LCM) of two integers.
  """
  def lcm(0, 0), do: 0
  def lcm(a, b), do: abs(div(a * b, gcd(a, b)))

  @doc """
  Checks if a number is prime.
  """
  def is_prime?(n) when n <= 1, do: false
  def is_prime?(2), do: true
  def is_prime?(n) when rem(n, 2) == 0, do: false

  def is_prime?(n) do
    limit = n |> :math.sqrt() |> Float.ceil() |> trunc()

    !Enum.any?(3..limit//2, fn i ->
      i < n && rem(n, i) == 0
    end)
  end

  @doc """
  Calculates factorial of a non-negative integer.
  """
  def factorial(n) when is_integer(n) and n >= 0, do: do_factorial(n, 1)

  def factorial(n) do
    raise ArgumentError, "factorial requires a non-negative integer, got: #{inspect(n)}"
  end

  # Tail-recursive: the body-recursive version built a stack frame per multiplication.
  defp do_factorial(0, acc), do: acc
  defp do_factorial(n, acc), do: do_factorial(n - 1, acc * n)

  @doc """
  Calculates combinations (n choose k) — the binomial coefficient.

  Returns an `t:integer/0`. A count of ways to choose things is never fractional,
  and the previous `factorial(n) / (factorial(k) * factorial(n - k))` returned a
  float, so `combinations(30, 15)` came back as `155117520.0` and anything past
  roughly `n = 60` silently lost precision to the float conversion.

  ## Examples

      iex> NumberF.Calculations.combinations(5, 2)
      10

      iex> NumberF.Calculations.combinations(30, 15)
      155_117_520
  """
  def combinations(n, k) when is_integer(n) and is_integer(k) and k >= 0 and k <= n do
    # Multiplicative formula: exact in integer arithmetic, and never builds a value
    # larger than the result itself. Each partial product is divisible by its own i.
    k = min(k, n - k)

    Enum.reduce(1..k//1, 1, fn i, acc -> div(acc * (n - k + i), i) end)
  end

  def combinations(n, k) do
    raise ArgumentError,
          "combinations requires integers with 0 <= k <= n, got: n=#{inspect(n)}, k=#{inspect(k)}"
  end

  @doc """
  Converts degrees to radians.
  """
  def to_radians(degrees), do: degrees * :math.pi() / 180.0

  @doc """
  Converts radians to degrees.
  """
  def to_degrees(radians), do: radians * 180.0 / :math.pi()
end

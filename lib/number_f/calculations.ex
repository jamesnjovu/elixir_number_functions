defmodule NumberF.Calculations do
  @moduledoc """
  General numeric calculation functions.
  """

  @doc """
  Calculates a percentage with specified precision.
  """
  def percentage(value, total, precision) do
    result = (value / total) * 100
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
    limit = :math.sqrt(n) |> Float.ceil() |> trunc()

    !Enum.any?(3..limit, fn i ->
      i < n && rem(n, i) == 0
    end)
  end

  @doc """
  Calculates factorial of a non-negative integer.
  """
  def factorial(0), do: 1
  def factorial(n) when n > 0, do: n * factorial(n - 1)

  @doc """
  Calculates combinations (n choose k).
  """
  def combinations(n, k) when k <= n do
    factorial(n) / (factorial(k) * factorial(n - k))
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

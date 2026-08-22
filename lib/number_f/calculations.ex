defmodule NumberF.Calculations do
  @moduledoc """
  General numeric calculation functions.
  """

  @doc """
  Calculates a percentage with specified precision.

  ## Edge cases

  A zero total raises `ArgumentError`. Letting the division run would surface an
  `ArithmeticError` from inside this function, which tells the caller nothing about
  which argument was wrong.

  ## Examples

      iex> NumberF.Calculations.percentage(25, 200, 2)
      12.5
  """
  def percentage(_value, 0, _precision), do: raise(ArgumentError, "total cannot be zero")
  def percentage(_value, +0.0, _precision), do: raise(ArgumentError, "total cannot be zero")

  def percentage(value, total, precision)
      when is_number(value) and is_number(total) and is_integer(precision) do
    Float.round(value / total * 100, precision)
  end

  @doc """
  Rounds a number to the nearest specified value.

  Always returns a float, matching `NumberF.round_to_nearest/2`. The two copies of
  this function had drifted — this one returned an integer for integer input while
  the facade multiplied by 1.0 — so callers got a different type depending on which
  module they reached for.

  ## Examples

      iex> NumberF.Calculations.round_to_nearest(12, 5)
      10.0

      iex> NumberF.Calculations.round_to_nearest(127, 5)
      125.0
  """
  def round_to_nearest(value, nearest \\ 1.0)

  def round_to_nearest(value, nearest) when is_number(value) and is_number(nearest) do
    round(value / nearest) * nearest * 1.0
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

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

  @doc """
  Number of ordered arrangements of k items from n (nPk).

  ## Examples

      iex> NumberF.Calculations.permutations(5, 2)
      20
  """
  def permutations(n, k) when is_integer(n) and is_integer(k) and k >= 0 and k <= n do
    Enum.reduce((n - k + 1)..n//1, 1, &(&1 * &2))
  end

  def permutations(n, k) do
    raise ArgumentError,
          "permutations requires integers with 0 <= k <= n, got: n=#{inspect(n)}, k=#{inspect(k)}"
  end

  @doc """
  The nth Fibonacci number, counting from `fibonacci(0) == 0`.

  ## Precision

  Iterative, so it is linear rather than exponential and stays exact for any n —
  Erlang integers are arbitrary precision, so `fibonacci(1000)` is the true value
  rather than a float approximation.

  ## Examples

      iex> NumberF.Calculations.fibonacci(10)
      55

      iex> NumberF.Calculations.fibonacci(0)
      0
  """
  def fibonacci(n) when is_integer(n) and n >= 0 do
    {result, _next} = Enum.reduce(1..n//1, {0, 1}, fn _, {a, b} -> {b, a + b} end)
    result
  end

  def fibonacci(n) do
    raise ArgumentError, "fibonacci requires a non-negative integer, got: #{inspect(n)}"
  end

  @doc """
  The first n Fibonacci numbers.

  ## Examples

      iex> NumberF.Calculations.fibonacci_sequence(8)
      [0, 1, 1, 2, 3, 5, 8, 13]
  """
  def fibonacci_sequence(n) when is_integer(n) and n >= 0 do
    Enum.map(0..(n - 1)//1, &fibonacci/1)
  end

  @doc """
  Prime factorisation, in ascending order and with repeats.

  ## Examples

      iex> NumberF.Calculations.prime_factors(360)
      [2, 2, 2, 3, 3, 5]

      iex> NumberF.Calculations.prime_factors(17)
      [17]
  """
  def prime_factors(n) when is_integer(n) and n > 1, do: do_prime_factors(n, 2, [])

  def prime_factors(n) when is_integer(n) and n in [0, 1], do: []

  def prime_factors(n) do
    raise ArgumentError, "prime_factors requires a non-negative integer, got: #{inspect(n)}"
  end

  defp do_prime_factors(1, _divisor, acc), do: Enum.reverse(acc)

  defp do_prime_factors(n, divisor, acc) when divisor * divisor > n,
    do: Enum.reverse([n | acc])

  defp do_prime_factors(n, divisor, acc) do
    if rem(n, divisor) == 0 do
      do_prime_factors(div(n, divisor), divisor, [divisor | acc])
    else
      # Step by two past 2: no even number above it can be a factor.
      do_prime_factors(n, if(divisor == 2, do: 3, else: divisor + 2), acc)
    end
  end

  @doc """
  All positive divisors of n, ascending.

  ## Examples

      iex> NumberF.Calculations.divisors(28)
      [1, 2, 4, 7, 14, 28]
  """
  def divisors(n) when is_integer(n) and n > 0 do
    limit = n |> :math.sqrt() |> trunc()

    1..limit//1
    |> Enum.filter(&(rem(n, &1) == 0))
    |> Enum.flat_map(&[&1, div(n, &1)])
    |> Enum.uniq()
    |> Enum.sort()
  end

  def divisors(n) do
    raise ArgumentError, "divisors requires a positive integer, got: #{inspect(n)}"
  end

  @doc """
  The decimal digits of an integer, most significant first.

  ## Examples

      iex> NumberF.Calculations.digits(12345)
      [1, 2, 3, 4, 5]

      iex> NumberF.Calculations.digits(-42)
      [4, 2]
  """
  def digits(n) when is_integer(n), do: Integer.digits(abs(n))

  @doc """
  Sum of the decimal digits.

  ## Examples

      iex> NumberF.Calculations.digit_sum(12345)
      15
  """
  def digit_sum(n) when is_integer(n), do: n |> digits() |> Enum.sum()

  @doc """
  Repeatedly sums the digits until one digit remains.

  ## Examples

      iex> NumberF.Calculations.digital_root(12345)
      6
  """
  def digital_root(n) when is_integer(n) do
    case digit_sum(n) do
      sum when sum < 10 -> sum
      sum -> digital_root(sum)
    end
  end

  @doc """
  The integer with its digits reversed. The sign is preserved.

  ## Examples

      iex> NumberF.Calculations.reverse_number(12345)
      54321

      iex> NumberF.Calculations.reverse_number(-120)
      -21
  """
  def reverse_number(n) when is_integer(n) do
    reversed = n |> digits() |> Enum.reverse() |> Integer.undigits()

    if n < 0, do: -reversed, else: reversed
  end

  @doc """
  Whether the decimal representation reads the same in both directions.

  ## Examples

      iex> NumberF.Calculations.palindrome?(12321)
      true

      iex> NumberF.Calculations.palindrome?(12345)
      false
  """
  def palindrome?(n) when is_integer(n) do
    d = digits(n)
    d == Enum.reverse(d)
  end

  @doc """
  Whether n is a perfect square.

  ## Precision

  Compares integers rather than testing `sqrt(n) == trunc(sqrt(n))`, which starts
  reporting false negatives once n exceeds the float mantissa.

  ## Examples

      iex> NumberF.Calculations.perfect_square?(144)
      true

      iex> NumberF.Calculations.perfect_square?(145)
      false
  """
  def perfect_square?(n) when is_integer(n) and n < 0, do: false

  def perfect_square?(n) when is_integer(n) do
    root = n |> :math.sqrt() |> Float.round() |> trunc()
    root * root == n
  end

  @doc """
  The real nth root of a number.

  ## Examples

      iex> NumberF.Calculations.nth_root(27, 3)
      3.0

      iex> NumberF.Calculations.nth_root(16, 4)
      2.0
  """
  def nth_root(number, n) when is_number(number) and is_number(n) and n != 0 do
    cond do
      number == 0 ->
        0.0

      number < 0 and rem(trunc(n), 2) == 0 ->
        raise ArgumentError,
              "no real even root of a negative number"

      number < 0 ->
        -Float.round(:math.pow(-number, 1 / n), 10)

      true ->
        Float.round(:math.pow(number, 1 / n), 10)
    end
  end

  @doc """
  Logarithm of a number in an arbitrary base.

  ## Examples

      iex> NumberF.Calculations.log_base(1024, 2)
      10.0

      iex> NumberF.Calculations.log_base(1000, 10)
      3.0
  """
  def log_base(number, base)
      when is_number(number) and is_number(base) and number > 0 and base > 0 and base != 1 do
    Float.round(:math.log(number) / :math.log(base), 10)
  end

  def log_base(number, base) do
    raise ArgumentError,
          "log_base requires a positive number and a positive base other than 1, got: " <>
            "#{inspect(number)}, #{inspect(base)}"
  end

  @doc """
  Renders an integer in an arbitrary base from 2 to 36.

  ## Examples

      iex> NumberF.Calculations.to_base(255, 16)
      "FF"

      iex> NumberF.Calculations.to_base(255, 2)
      "11111111"
  """
  def to_base(number, base)
      when is_integer(number) and is_integer(base) and base >= 2 and base <= 36 do
    Integer.to_string(number, base)
  end

  def to_base(number, base) do
    raise ArgumentError,
          "to_base requires an integer and a base in 2..36, got: #{inspect(number)}, #{inspect(base)}"
  end

  @doc """
  Parses an integer written in an arbitrary base from 2 to 36.

  ## Examples

      iex> NumberF.Calculations.from_base("FF", 16)
      255

      iex> NumberF.Calculations.from_base("11111111", 2)
      255
  """
  def from_base(string, base)
      when is_binary(string) and is_integer(base) and base >= 2 and base <= 36 do
    case Integer.parse(string, base) do
      {value, ""} -> value
      _ -> raise ArgumentError, "#{inspect(string)} is not a valid base-#{base} integer"
    end
  end

  @doc """
  Renders an integer in hexadecimal.

  ## Examples

      iex> NumberF.Calculations.to_hex(255)
      "FF"
  """
  def to_hex(number), do: to_base(number, 16)

  @doc """
  Parses a hexadecimal integer.

  ## Examples

      iex> NumberF.Calculations.from_hex("FF")
      255
  """
  def from_hex(string), do: from_base(string, 16)

  @doc """
  Renders an integer in binary.

  ## Examples

      iex> NumberF.Calculations.to_binary(5)
      "101"
  """
  def to_binary(number), do: to_base(number, 2)

  @doc """
  Parses a binary integer.

  ## Examples

      iex> NumberF.Calculations.from_binary("101")
      5
  """
  def from_binary(string), do: from_base(string, 2)

  @doc """
  Renders an integer in octal.

  ## Examples

      iex> NumberF.Calculations.to_octal(8)
      "10"
  """
  def to_octal(number), do: to_base(number, 8)

  @doc """
  Parses an octal integer.

  ## Examples

      iex> NumberF.Calculations.from_octal("10")
      8
  """
  def from_octal(string), do: from_base(string, 8)
end

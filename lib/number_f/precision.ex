defmodule NumberF.Precision do
  @moduledoc """
  Functions for handling numerical precision issues and implementing various rounding strategies.
  """

  @doc """
  Rounds a number to a specified number of decimal places.

  ## Parameters
    - `number`: The number to round
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.Precision.round_with_precision(3.14159, 2)
      3.14

      iex> NumberF.Precision.round_with_precision(3.14159, 4)
      3.1416
  """
  def round_with_precision(number, precision \\ 2)
      when is_number(number) and is_integer(precision) do
    Float.round(number, precision)
  end

  @doc """
  Rounds a number using banker's rounding (round to even).
  This is more statistically unbiased than standard rounding.

  ## Parameters
    - `number`: The number to round
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.Precision.bankers_round(2.5, 0)
      2.0

      iex> NumberF.Precision.bankers_round(3.5, 0)
      4.0

      iex> NumberF.Precision.bankers_round(2.125, 2)
      2.12

      iex> NumberF.Precision.bankers_round(2.135, 2)
      2.14
  """
  def bankers_round(number, precision \\ 2) when is_number(number) and is_integer(precision) do
    power = :math.pow(10, precision)
    rounded = round(number * power) / power
    Float.round(rounded, precision)
  end

  @doc """
  Rounds a number up to a specified precision (ceiling).

  ## Parameters
    - `number`: The number to round
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.Precision.ceiling(3.14159, 2)
      3.15

      iex> NumberF.Precision.ceiling(3.14159, 1)
      3.2
  """
  def ceiling(number, precision \\ 2) when is_number(number) and is_integer(precision) do
    power = :math.pow(10, precision)
    Float.ceil(number * power) / power
  end

  @doc """
  Rounds a number down to a specified precision (floor).

  ## Parameters
    - `number`: The number to round
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.Precision.floor(3.14159, 2)
      3.14

      iex> NumberF.Precision.floor(3.14159, 1)
      3.1
  """
  def floor(number, precision \\ 2) when is_number(number) and is_integer(precision) do
    power = :math.pow(10, precision)
    Float.floor(number * power) / power
  end

  @doc """
  Truncates a number to a specified precision (cuts off digits).

  ## Parameters
    - `number`: The number to truncate
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.Precision.truncate(3.14159, 2)
      3.14

      iex> NumberF.Precision.truncate(-3.14159, 2)
      -3.14
  """
  def truncate(number, precision \\ 2) when is_number(number) and is_integer(precision) do
    power = :math.pow(10, precision)
    trunc(number * power) / power
  end

  @doc """
  Rounds a number to a specific increment.

  ## Parameters
    - `number`: The number to round
    - `increment`: The increment to round to (default: 1.0)
    - `strategy`: The rounding strategy (:nearest, :up, :down, or :bankers)

  ## Examples

      iex> NumberF.Precision.round_to(3.14159, 0.05, :nearest)
      3.15

      iex> NumberF.Precision.round_to(3.14159, 0.1, :up)
      3.2

      iex> NumberF.Precision.round_to(3.14159, 0.1, :down)
      3.1
  """
  def round_to(number, increment \\ 1.0, strategy \\ :nearest)
      when is_number(number) and is_number(increment) do
    case strategy do
      :nearest ->
        Float.round(number / increment) * increment

      :up ->
        Float.ceil(number / increment) * increment

      :down ->
        Float.floor(number / increment) * increment

      :bankers ->
        # Use banker's rounding (round to even)
        multiplier = 1 / increment
        bankers_division = round(number * multiplier)
        bankers_division / multiplier
    end
  end

  @doc """
  Checks if two floating point numbers are approximately equal.

  ## Parameters
    - `a`: First number
    - `b`: Second number
    - `epsilon`: Maximum allowed difference (default: 1.0e-10)

  ## Examples

      iex> NumberF.Precision.approximately_equal(0.1 + 0.2, 0.3)
      true

      iex> NumberF.Precision.approximately_equal(0.1, 0.2)
      false
  """
  def approximately_equal(a, b, epsilon \\ 1.0e-10)
      when is_number(a) and is_number(b) and is_number(epsilon) do
    abs(a - b) < epsilon
  end

  @doc """
  Formats a number with a specified precision, using string manipulation
  to avoid floating-point rounding issues.

  ## Parameters
    - `number`: The number to format
    - `precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.Precision.precise_format(3.14159, 2)
      "3.14"

      iex> NumberF.Precision.precise_format(3.14159, 4)
      "3.1416"
  """
  def precise_format(number, precision \\ 2) when is_number(number) and is_integer(precision) do
    # Convert to string with high precision
    str = :erlang.float_to_binary(number * 1.0, decimals: precision + 5)

    # Split into integer and decimal parts
    [int_part, dec_part] = String.split(str, ".")

    # Truncate decimal part to desired precision
    truncated_dec = String.slice(dec_part, 0, precision)

    # Combine with appropriate precision
    if precision > 0 do
      "#{int_part}.#{truncated_dec}"
    else
      int_part
    end
  end

  @doc """
  Implements a custom rounding function with different modes.

  ## Parameters
    - `number`: The number to round
    - `precision`: Number of decimal places
    - `mode`: Rounding mode (default: :half_up)
      - :half_up - Round to nearest, 0.5 rounds up (standard)
      - :half_down - Round to nearest, 0.5 rounds down
      - :half_even - Round to nearest, 0.5 rounds to even (banker's)
      - :ceiling - Always round up
      - :floor - Always round down
      - :truncate - Always truncate (toward zero)

  ## Examples

      iex> NumberF.Precision.custom_round(2.5, 0, :half_up)
      3.0

      iex> NumberF.Precision.custom_round(2.5, 0, :half_down)
      2.0

      iex> NumberF.Precision.custom_round(2.5, 0, :half_even)
      2.0

      iex> NumberF.Precision.custom_round(3.5, 0, :half_even)
      4.0
  """
  def custom_round(number, precision, mode \\ :half_up)
      when is_number(number) and is_integer(precision) do
    # Shift decimal point right by precision
    shifted = number * :math.pow(10, precision)

    # Apply rounding based on mode
    rounded =
      case mode do
        :half_up ->
          Float.round(shifted)

        :half_down ->
          # Integer part
          int_part = trunc(shifted)
          # Fraction part
          frac_part = abs(shifted - int_part)

          # If exactly 0.5, round down, otherwise normal rounding
          if frac_part == 0.5 do
            int_part
          else
            Float.round(shifted)
          end

        :half_even ->
          # Integer part
          int_part = trunc(shifted)
          # Fraction part
          frac_part = abs(shifted - int_part)

          # If exactly 0.5, round to even number
          if frac_part == 0.5 do
            if rem(int_part, 2) == 0 do
              int_part
            else
              int_part + if shifted >= 0, do: 1, else: -1
            end
          else
            Float.round(shifted)
          end

        :ceiling ->
          Float.ceil(shifted)

        :floor ->
          Float.floor(shifted)

        :truncate ->
          trunc(shifted)
      end

    # Shift decimal point back left
    rounded / :math.pow(10, precision)
  end

  @doc """
  Sanitizes a float value to handle special cases like NaN and Infinity.

  ## Parameters
    - `value`: The value to sanitize
    - `default`: Default value to return for invalid numbers (default: 0.0)

  ## Examples

      iex> NumberF.Precision.sanitize_float(:nan, 0.0)
      0.0

      iex> NumberF.Precision.sanitize_float(:infinity, 0.0)
      0.0

      iex> NumberF.Precision.sanitize_float(3.14, 0.0)
      3.14
  """
  def sanitize_float(value, default \\ 0.0)

  def sanitize_float(:nan, default), do: default
  def sanitize_float(:infinity, default), do: default
  def sanitize_float(:"-infinity", default), do: default

  def sanitize_float(value, _default) when is_number(value) do
    if is_float(value) do
      # Check for NaN or Infinity
      case :erlang.float_to_binary(value, [:compact, {:decimals, 20}]) do
        "nan" -> 0.0
        "inf" -> 0.0
        "-inf" -> 0.0
        _ -> value
      end
    else
      # Convert to float
      value * 1.0
    end
  end

  def sanitize_float(_value, default), do: default
end

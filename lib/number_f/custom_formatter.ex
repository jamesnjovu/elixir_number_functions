defmodule NumberF.CustomFormatter do
  @moduledoc """
  Custom implementations for number formatting functions.
  Replaces functionality from the 'number' dependency.
  """

  @doc """
  Formats a number as currency with specified unit and precision.

  ## Examples
      iex> NumberF.CustomFormatter.number_to_currency(1234.56, unit: "USD", precision: 2)
      "USD 1,234.56"

      iex> NumberF.CustomFormatter.number_to_currency("1234.56", unit: "USD", precision: 2)
      "USD 1,234.56"
  """
  def number_to_currency(number, opts \\ [])

  # Add a specific clause for Decimal type
  def number_to_currency(%Decimal{} = decimal, opts) do
    # Convert Decimal to float for processing
    decimal
    |> Decimal.to_float()
    |> number_to_currency(opts)
  end

  def number_to_currency(number, opts) when is_binary(number) do
    case Float.parse(number) do
      {float, _} -> number_to_currency(float, opts)
      :error -> raise ArgumentError, "could not convert #{inspect(number)} to number"
    end
  end

  # Handle integers directly without converting to float first
  def number_to_currency(number, opts) when is_integer(number) do
    unit = Keyword.get(opts, :unit, "")
    precision = Keyword.get(opts, :precision, 2)
    delimiter = Keyword.get(opts, :delimiter, ",")
    separator = Keyword.get(opts, :separator, ".")

    # Format the integer with delimiters
    formatted = format_integer_with_delimiters(number, delimiter, separator, precision)

    # Add currency unit if provided
    if unit == "" do
      formatted
    else
      "#{unit} #{formatted}"
    end
  end

  def number_to_currency(number, opts) when is_float(number) do
    unit = Keyword.get(opts, :unit, "")
    precision = Keyword.get(opts, :precision, 2)
    delimiter = Keyword.get(opts, :delimiter, ",")
    separator = Keyword.get(opts, :separator, ".")

    # Format the number with proper precision
    formatted =
      number
      |> Float.round(precision)
      |> format_with_delimiters(delimiter, separator, precision)

    # Add currency unit if provided
    if unit == "" do
      formatted
    else
      "#{unit} #{formatted}"
    end
  end

  @doc """
  Formats a number with delimiters for thousands and decimal separator.

  ## Examples
      iex> NumberF.CustomFormatter.number_to_delimited(1234567.89, delimiter: ",", separator: ".", precision: 2)
      "1,234,567.89"

      iex> NumberF.CustomFormatter.number_to_delimited("1234567.89", delimiter: ",", separator: ".", precision: 2)
      "1,234,567.89"
  """
  def number_to_delimited(number, opts \\ [])

  # Add support for Decimal type
  def number_to_delimited(%Decimal{} = decimal, opts) do
    decimal
    |> Decimal.to_float()
    |> number_to_delimited(opts)
  end

  def number_to_delimited(number, opts) when is_binary(number) do
    case Float.parse(number) do
      {float, _} -> number_to_delimited(float, opts)
      :error -> raise ArgumentError, "could not convert #{inspect(number)} to number"
    end
  end

  # Handle integers directly
  def number_to_delimited(number, opts) when is_integer(number) do
    delimiter = Keyword.get(opts, :delimiter, ",")
    separator = Keyword.get(opts, :separator, ".")
    precision = Keyword.get(opts, :precision, 2)

    format_integer_with_delimiters(number, delimiter, separator, precision)
  end

  def number_to_delimited(number, opts) when is_float(number) do
    delimiter = Keyword.get(opts, :delimiter, ",")
    separator = Keyword.get(opts, :separator, ".")
    precision = Keyword.get(opts, :precision, 2)

    format_with_delimiters(number, delimiter, separator, precision)
  end

  @doc """
  Converts a value to a float.

  ## Examples
      iex> NumberF.CustomFormatter.to_float("123.45")
      123.45

      iex> NumberF.CustomFormatter.to_float(123)
      123.0
  """
  def to_float(value) when is_float(value), do: value
  def to_float(value) when is_integer(value), do: value * 1.0
  def to_float(%Decimal{} = value), do: Decimal.to_float(value)

  def to_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float, _} -> float
      :error -> raise ArgumentError, "could not convert #{inspect(value)} to float"
    end
  end

  @doc """
  Converts a value to an integer.

  ## Edge cases

  Accepts integers unchanged. Guarding this was not academic: the previous
  implementation called `Integer.parse/1` unguarded, so it raised on the very type
  it returns. Floats are truncated toward zero, matching `trunc/1`.

  ## Examples

      iex> NumberF.CustomFormatter.to_int("123.45")
      123

      iex> NumberF.CustomFormatter.to_int(12)
      12

      iex> NumberF.CustomFormatter.to_int(3.9)
      3
  """
  def to_int(value) when is_integer(value), do: value
  def to_int(value) when is_float(value), do: trunc(value)

  def to_int(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _rest} -> int
      :error -> raise ArgumentError, "could not convert #{inspect(value)} to an integer"
    end
  end

  def to_int(value) do
    raise ArgumentError, "could not convert #{inspect(value)} to an integer"
  end

  @doc """
  Converts a string to a boolean.

  Recognises `"true"/"yes"/"on"` and `"false"/"no"/"off"`, case-insensitively.
  Anything else raises rather than guessing.

  ## Examples

      iex> NumberF.CustomFormatter.to_boolean("YES")
      true

      iex> NumberF.CustomFormatter.to_boolean("off")
      false
  """
  def to_boolean(value) when is_binary(value) do
    case String.downcase(value) do
      t when t in ["true", "yes", "on"] -> true
      f when f in ["false", "no", "off"] -> false
      _ -> raise ArgumentError, "could not convert #{inspect(value)} to boolean"
    end
  end

  def to_boolean(value) do
    raise ArgumentError, "could not convert #{inspect(value)} to boolean"
  end

  @doc """
  Sums a list of `Decimal` values, flattening any nesting.

  ## Examples

      iex> NumberF.CustomFormatter.sum_decimal([Decimal.new("1.10"), Decimal.new("2.20")])
      Decimal.new("3.30")
  """
  def sum_decimal(list) when is_list(list) do
    list
    |> List.flatten()
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&1, &2))
  end

  @doc """
  Converts a value to a Decimal.

  ## Examples
      iex> NumberF.CustomFormatter.to_decimal("123.45")
      Decimal.new("123.45")

      iex> NumberF.CustomFormatter.to_decimal(123)
      Decimal.new("123")
  """
  def to_decimal(value) when is_binary(value) do
    Decimal.new(value)
  rescue
    error ->
      # reraise, not raise: a bare raise here would discard the stacktrace that
      # points at whatever inside Decimal actually rejected the input.
      _ = error

      reraise ArgumentError.exception("could not convert #{inspect(value)} to decimal"),
              __STACKTRACE__
  end

  def to_decimal(value) when is_integer(value), do: Decimal.new(value)
  def to_decimal(value) when is_float(value), do: Decimal.from_float(value)
  def to_decimal(%Decimal{} = value), do: value

  # New helper function to format integers with delimiters
  defp format_integer_with_delimiters(number, delimiter, separator, precision) do
    # Handle negative numbers
    {sign, abs_number} = if number < 0, do: {"-", abs(number)}, else: {"", number}

    # Convert integer to string and add delimiters
    int_str = Integer.to_string(abs_number)

    formatted_int =
      int_str
      |> String.to_charlist()
      |> Enum.reverse()
      |> Enum.chunk_every(3)
      |> Enum.map(&Enum.reverse/1)
      |> Enum.reverse()
      |> Enum.join(delimiter)

    # Add decimal part if precision > 0
    result =
      if precision > 0 do
        decimal_part = String.duplicate("0", precision)
        "#{formatted_int}#{separator}#{decimal_part}"
      else
        formatted_int
      end

    # Add sign back
    "#{sign}#{result}"
  end

  # Every caller reaches this with a float: number_to_delimited/2 routes integers to
  # format_integer_with_delimiters/4, and number_to_currency/2 pipes through
  # Float.round/2 first. The guard states that instead of leaving it implicit.
  defp format_with_delimiters(float_number, delimiter, separator, precision)
       when is_float(float_number) do
    # Handle negative numbers
    {sign, abs_number} =
      if float_number < 0, do: {"-", abs(float_number)}, else: {"", float_number}

    # Round the number to the required precision
    rounded_number = Float.round(abs_number, precision)

    # Convert to string and split into integer and decimal parts
    # Use :erlang.float_to_binary to avoid scientific notation
    number_str = :erlang.float_to_binary(rounded_number, [:compact, {:decimals, precision}])
    parts = String.split(number_str, ".")

    # Handle both integer and float cases
    [int_part | dec_parts] = parts

    # Add delimiters to the integer part
    formatted_int =
      int_part
      |> String.to_charlist()
      |> Enum.reverse()
      |> Enum.chunk_every(3)
      |> Enum.map(&Enum.reverse/1)
      |> Enum.reverse()
      |> Enum.join(delimiter)

    # Format decimal part to have exactly the specified precision
    formatted_dec =
      if precision > 0 do
        dec_part =
          case dec_parts do
            [part] -> part
            [] -> ""
          end

        dec_formatted =
          dec_part
          |> String.pad_trailing(precision, "0")
          |> String.slice(0, precision)

        "#{separator}#{dec_formatted}"
      else
        ""
      end

    # Add sign back
    "#{sign}#{formatted_int}#{formatted_dec}"
  end
end

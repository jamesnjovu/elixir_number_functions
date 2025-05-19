
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

  def number_to_currency(number, opts) when is_integer(number) do
    number_to_currency(number * 1.0, opts)
  end

  def number_to_currency(number, opts) when is_float(number) do
    unit = Keyword.get(opts, :unit, "")
    precision = Keyword.get(opts, :precision, 2)
    delimiter = Keyword.get(opts, :delimiter, ",")
    separator = Keyword.get(opts, :separator, ".")

    # Format the number with proper precision
    formatted = number
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

  def number_to_delimited(number, opts) when is_integer(number) do
    number_to_delimited(number * 1.0, opts)
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
  Converts a value to a Decimal.

  ## Examples
      iex> NumberF.CustomFormatter.to_decimal("123.45")
      #Decimal<123.45>

      iex> NumberF.CustomFormatter.to_decimal(123)
      #Decimal<123>
  """
  def to_decimal(value) when is_binary(value) do
    Decimal.new(value)
  rescue
    _ -> raise ArgumentError, "could not convert #{inspect(value)} to decimal"
  end
  def to_decimal(value) when is_integer(value), do: Decimal.new(value)
  def to_decimal(value) when is_float(value), do: Decimal.from_float(value)
  def to_decimal(%Decimal{} = value), do: value

  # Private helper function to format a number with delimiters
  defp format_with_delimiters(number, delimiter, separator, precision) do
    # Ensure number is a float
    float_number = ensure_float(number)

    # Round the number to the required precision
    rounded_number = Float.round(float_number, precision)

    # Convert to string and split into integer and decimal parts
    number_str = Float.to_string(rounded_number)
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
        dec_part = case dec_parts do
          [part] -> part
          [] -> ""
        end
        dec_formatted = String.pad_trailing(dec_part, precision, "0")
                        |> String.slice(0, precision)
        "#{separator}#{dec_formatted}"
      else
        ""
      end

    formatted_int <> formatted_dec
  end

  # Helper to ensure a number is a float
  defp ensure_float(num) when is_float(num), do: num
  defp ensure_float(num) when is_integer(num), do: num * 1.0
  defp ensure_float(%Decimal{} = num), do: Decimal.to_float(num)
end

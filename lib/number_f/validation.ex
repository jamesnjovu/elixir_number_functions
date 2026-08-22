defmodule NumberF.Validation do
  @moduledoc """
  Functions for validating various numeric formats and related data.
  """

  @doc """
  Checks if a string is a valid number format.
  """
  def is_valid_number?(str) when is_binary(str) do
    case Float.parse(str) do
      {_num, ""} -> true
      _ -> false
    end
  end

  def is_valid_number?(_), do: false

  @doc """
  Checks if a string is a valid integer.
  """
  def is_valid_integer?(str) when is_binary(str) do
    case Integer.parse(str) do
      {_num, ""} -> true
      _ -> false
    end
  end

  def is_valid_integer?(_), do: false

  @doc """
  Validates credit card numbers using the Luhn algorithm.
  """
  def is_valid_credit_card?(number, type \\ :any)

  def is_valid_credit_card?(number, type) when is_binary(number) do
    # Remove any spaces or dashes
    cleaned = String.replace(number, ~r/[\s-]/, "")

    # Check if all characters are digits
    if Regex.match?(~r/^\d+$/, cleaned) do
      # Validate card type by pattern
      card_valid? =
        case type do
          :visa -> Regex.match?(~r/^4[0-9]{12}(?:[0-9]{3})?$/, cleaned)
          :mastercard -> Regex.match?(~r/^5[1-5][0-9]{14}$/, cleaned)
          :amex -> Regex.match?(~r/^3[47][0-9]{13}$/, cleaned)
          :discover -> Regex.match?(~r/^6(?:011|5[0-9]{2})[0-9]{12}$/, cleaned)
          :any -> true
        end

      if card_valid? do
        luhn_valid?(cleaned)
      else
        false
      end
    else
      false
    end
  end

  def is_valid_credit_card?(_, _), do: false

  # Luhn algorithm implementation
  defp luhn_valid?(number) do
    digits = number |> String.graphemes() |> Enum.map(&String.to_integer/1)

    # Double every second digit from right to left
    doubled =
      digits
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(fn {digit, i} ->
        if rem(i, 2) == 1 do
          case digit * 2 do
            n when n > 9 -> n - 9
            n -> n
          end
        else
          digit
        end
      end)
      |> Enum.sum()

    rem(doubled, 10) == 0
  end

  @doc """
  Validates an IBAN using the ISO 13616 mod-97 checksum.

  ## Edge cases

  Checks structure and checksum only. A well-formed IBAN can still name an account
  that does not exist; only the receiving bank can confirm that.

  ## Examples

      iex> NumberF.Validation.valid_iban?("GB82 WEST 1234 5698 7654 32")
      true

      iex> NumberF.Validation.valid_iban?("GB82 WEST 1234 5698 7654 33")
      false
  """
  def valid_iban?(iban) when is_binary(iban) do
    normalised = iban |> String.replace(~r/\s/, "") |> String.upcase()

    with true <- Regex.match?(~r/^[A-Z]{2}\d{2}[A-Z0-9]{1,30}$/, normalised),
         {front, back} <- String.split_at(normalised, 4),
         rearranged <- back <> front,
         {:ok, numeric} <- iban_to_number(rearranged) do
      rem(numeric, 97) == 1
    else
      _ -> false
    end
  end

  def valid_iban?(_iban), do: false

  # Each letter becomes its 1-based position plus 9, per ISO 13616. The result is
  # far wider than 64 bits, which is fine — Erlang integers are arbitrary precision.
  defp iban_to_number(string) do
    digits =
      string
      |> String.to_charlist()
      |> Enum.map(fn
        c when c in ?0..?9 -> to_string(c - ?0)
        c when c in ?A..?Z -> to_string(c - ?A + 10)
        _ -> nil
      end)

    if Enum.any?(digits, &is_nil/1) do
      :error
    else
      {:ok, digits |> Enum.join() |> String.to_integer()}
    end
  end

  @doc """
  Validates an ISBN-10 or ISBN-13, with or without separators.

  ## Examples

      iex> NumberF.Validation.valid_isbn?("978-3-16-148410-0")
      true

      iex> NumberF.Validation.valid_isbn?("0-306-40615-2")
      true

      iex> NumberF.Validation.valid_isbn?("0-306-40615-3")
      false
  """
  def valid_isbn?(isbn) when is_binary(isbn) do
    case isbn |> String.replace(~r/[\s-]/, "") |> String.upcase() do
      <<digits::binary-size(10)>> -> isbn10_valid?(digits)
      <<digits::binary-size(13)>> -> ean_checksum_valid?(digits)
      _ -> false
    end
  end

  def valid_isbn?(_isbn), do: false

  defp isbn10_valid?(digits) do
    # The final character may be X, standing for 10.
    values =
      digits
      |> String.to_charlist()
      |> Enum.map(fn
        ?X -> 10
        c when c in ?0..?9 -> c - ?0
        _ -> nil
      end)

    if Enum.any?(values, &is_nil/1) or Enum.any?(Enum.take(values, 9), &(&1 == 10)) do
      false
    else
      total =
        values
        |> Enum.with_index(1)
        |> Enum.reduce(0, fn {value, position}, acc -> acc + value * position end)

      rem(total, 11) == 0
    end
  end

  @doc """
  Validates an EAN-8 or EAN-13 barcode checksum.

  ## Examples

      iex> NumberF.Validation.valid_ean?("4006381333931")
      true

      iex> NumberF.Validation.valid_ean?("4006381333932")
      false
  """
  def valid_ean?(code) when is_binary(code) do
    digits = String.replace(code, ~r/[\s-]/, "")

    if String.length(digits) in [8, 13], do: ean_checksum_valid?(digits), else: false
  end

  def valid_ean?(_code), do: false

  @doc """
  Validates a 12-digit UPC-A barcode checksum.

  ## Examples

      iex> NumberF.Validation.valid_upc?("036000291452")
      true
  """
  def valid_upc?(code) when is_binary(code) do
    digits = String.replace(code, ~r/[\s-]/, "")

    if String.length(digits) == 12, do: ean_checksum_valid?(digits), else: false
  end

  def valid_upc?(_code), do: false

  # EAN/UPC/ISBN-13 all share one checksum: alternating weights of 1 and 3 applied
  # from the right, with the total required to be a multiple of ten.
  defp ean_checksum_valid?(digits) do
    if Regex.match?(~r/^\d+$/, digits) do
      total =
        digits
        |> String.to_charlist()
        |> Enum.reverse()
        |> Enum.with_index()
        |> Enum.reduce(0, fn {char, index}, acc ->
          weight = if rem(index, 2) == 0, do: 1, else: 3
          acc + (char - ?0) * weight
        end)

      rem(total, 10) == 0
    else
      false
    end
  end

  @doc """
  Identifies a card network from its number, by prefix and length.

  Returns `:visa`, `:mastercard`, `:amex`, `:discover`, `:diners`, `:jcb`,
  `:unionpay`, `:maestro` or `:unknown`. This is presentational — it does not
  validate the number. Combine with `is_valid_credit_card?/1`.

  ## Examples

      iex> NumberF.Validation.card_brand("4111111111111111")
      :visa

      iex> NumberF.Validation.card_brand("5500000000000004")
      :mastercard

      iex> NumberF.Validation.card_brand("378282246310005")
      :amex

      iex> NumberF.Validation.card_brand("1234")
      :unknown
  """
  def card_brand(number) when is_binary(number) do
    digits = String.replace(number, ~r/[\s-]/, "")
    length = String.length(digits)

    cond do
      not Regex.match?(~r/^\d+$/, digits) -> :unknown
      Regex.match?(~r/^4\d{12}(\d{3})?(\d{3})?$/, digits) -> :visa
      Regex.match?(~r/^(5[1-5]|2[2-7])/, digits) and length == 16 -> :mastercard
      Regex.match?(~r/^3[47]/, digits) and length == 15 -> :amex
      Regex.match?(~r/^(6011|65|64[4-9])/, digits) and length == 16 -> :discover
      Regex.match?(~r/^3(0[0-5]|[68])/, digits) and length in [14, 15] -> :diners
      Regex.match?(~r/^35(2[89]|[3-8])/, digits) and length == 16 -> :jcb
      Regex.match?(~r/^62/, digits) and length in 16..19 -> :unionpay
      Regex.match?(~r/^(50|5[6-9]|6)/, digits) and length in 12..19 -> :maestro
      true -> :unknown
    end
  end

  def card_brand(_number), do: :unknown

  @doc """
  Computes the Luhn check digit for a number that does not yet have one.

  ## Examples

      iex> NumberF.Validation.luhn_check_digit("411111111111111")
      1
  """
  def luhn_check_digit(partial) when is_binary(partial) do
    digits = String.replace(partial, ~r/[\s-]/, "")

    unless Regex.match?(~r/^\d+$/, digits) do
      raise ArgumentError, "luhn_check_digit expects digits, got: #{inspect(partial)}"
    end

    total =
      digits
      |> String.to_charlist()
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.reduce(0, fn {char, index}, acc ->
        digit = char - ?0
        # The appended check digit shifts every position by one, so doubling
        # applies to even indices here rather than odd ones.
        doubled = if rem(index, 2) == 0, do: digit * 2, else: digit
        acc + if doubled > 9, do: doubled - 9, else: doubled
      end)

    rem(10 - rem(total, 10), 10)
  end

  @doc """
  Validates any Luhn-checksummed number, not just payment cards.

  ## Examples

      iex> NumberF.Validation.valid_luhn?("4111111111111111")
      true

      iex> NumberF.Validation.valid_luhn?("4111111111111112")
      false
  """
  def valid_luhn?(number) when is_binary(number) do
    digits = String.replace(number, ~r/[\s-]/, "")

    if Regex.match?(~r/^\d+$/, digits) and String.length(digits) > 1 do
      {body, <<check::binary-size(1)>>} = String.split_at(digits, -1)
      luhn_check_digit(body) == String.to_integer(check)
    else
      false
    end
  end

  def valid_luhn?(_number), do: false

  @doc """
  Validates a US ABA routing number by its weighted checksum.

  ## Examples

      iex> NumberF.Validation.valid_routing_number?("021000021")
      true

      iex> NumberF.Validation.valid_routing_number?("021000022")
      false
  """
  def valid_routing_number?(number) when is_binary(number) do
    digits = String.replace(number, ~r/[\s-]/, "")

    if Regex.match?(~r/^\d{9}$/, digits) do
      weights = [3, 7, 1, 3, 7, 1, 3, 7, 1]

      total =
        digits
        |> String.to_charlist()
        |> Enum.zip(weights)
        |> Enum.reduce(0, fn {char, weight}, acc -> acc + (char - ?0) * weight end)

      rem(total, 10) == 0
    else
      false
    end
  end

  def valid_routing_number?(_number), do: false

  @doc """
  Validates a 15-digit IMEI, which uses the Luhn checksum.

  ## Examples

      iex> NumberF.Validation.valid_imei?("490154203237518")
      true
  """
  def valid_imei?(imei) when is_binary(imei) do
    digits = String.replace(imei, ~r/[\s-]/, "")

    Regex.match?(~r/^\d{15}$/, digits) and valid_luhn?(digits)
  end

  def valid_imei?(_imei), do: false

  @doc """
  Checks that a code is a currency this library knows about.

  ## Examples

      iex> NumberF.Validation.valid_currency_code?("USD")
      true

      iex> NumberF.Validation.valid_currency_code?("XYZ")
      false
  """
  def valid_currency_code?(code) when is_binary(code) do
    Map.has_key?(NumberF.Currencies.currency_data(), String.upcase(code))
  end

  def valid_currency_code?(_code), do: false

  @doc """
  Checks that a value is a number in the 0..100 range.

  ## Examples

      iex> NumberF.Validation.valid_percentage?(42.5)
      true

      iex> NumberF.Validation.valid_percentage?(101)
      false
  """
  def valid_percentage?(value) when is_number(value), do: value >= 0 and value <= 100
  def valid_percentage?(_value), do: false
end

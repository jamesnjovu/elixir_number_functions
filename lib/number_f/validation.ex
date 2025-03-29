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
      card_valid? = case type do
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
    digits = String.graphemes(number) |> Enum.map(&String.to_integer/1)

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
end

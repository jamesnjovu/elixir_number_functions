defmodule NumberF.Formatter do
  @moduledoc """
  Functions for formatting numbers and related data in various formats.
  """

  @doc """
  Formats phone numbers based on country code.
  """
  def format_phone(number, country_code) when is_binary(number) do
    # Remove any non-digit characters
    digits = String.replace(number, ~r/\D/, "")

    case country_code do
      "ZM" ->
        if String.starts_with?(digits, "260") do
          "+260 " <>
            String.slice(digits, 3, 2) <>
            " " <>
            String.slice(digits, 5, 3) <> " " <> String.slice(digits, 8, 4)
        else
          "0" <>
            String.slice(digits, 0, 2) <>
            " " <>
            String.slice(digits, 2, 3) <> " " <> String.slice(digits, 5, 4)
        end

      "US" ->
        if String.starts_with?(digits, "1") and String.length(digits) == 11 do
          "+1 (" <>
            String.slice(digits, 1, 3) <>
            ") " <>
            String.slice(digits, 4, 3) <> "-" <> String.slice(digits, 7, 4)
        else
          "(" <>
            String.slice(digits, 0, 3) <>
            ") " <>
            String.slice(digits, 3, 3) <> "-" <> String.slice(digits, 6, 4)
        end

      "UK" ->
        if String.starts_with?(digits, "44") do
          "+44 " <>
            String.slice(digits, 2, 2) <>
            " " <>
            String.slice(digits, 4, 4) <> " " <> String.slice(digits, 8, 4)
        else
          "0" <>
            String.slice(digits, 0, 2) <>
            " " <>
            String.slice(digits, 2, 4) <> " " <> String.slice(digits, 6, 4)
        end

      _ ->
        # Generic international format
        "+" <> digits
    end
  end

  @doc """
  Formats large numbers as K, M, B (e.g., 1.2K, 3.4M).
  """
  def abbreviate_number(number, precision) when is_number(number) do
    cond do
      number >= 1_000_000_000 ->
        "#{Float.round(number / 1_000_000_000, precision)}B"

      number >= 1_000_000 ->
        "#{Float.round(number / 1_000_000, precision)}M"

      number >= 1_000 ->
        "#{Float.round(number / 1_000, precision)}K"

      true ->
        "#{number}"
    end
  end

  @doc """
  Converts numbers to ordinals (1st, 2nd, 3rd, etc.).
  """
  def ordinal(number) when is_integer(number) and number > 0 do
    suffix =
      cond do
        rem(number, 100) in [11, 12, 13] -> "th"
        rem(number, 10) == 1 -> "st"
        rem(number, 10) == 2 -> "nd"
        rem(number, 10) == 3 -> "rd"
        true -> "th"
      end

    "#{number}#{suffix}"
  end

  @doc """
  Converts Arabic numbers to Roman numerals.
  """
  def to_roman(number) when is_integer(number) and number > 0 and number < 4000 do
    roman_map = [
      {1000, "M"},
      {900, "CM"},
      {500, "D"},
      {400, "CD"},
      {100, "C"},
      {90, "XC"},
      {50, "L"},
      {40, "XL"},
      {10, "X"},
      {9, "IX"},
      {5, "V"},
      {4, "IV"},
      {1, "I"}
    ]

    {_num, result} =
      Enum.reduce(roman_map, {number, ""}, fn {val, rom}, {num, acc} ->
        count = div(num, val)
        remainder = rem(num, val)
        {remainder, acc <> String.duplicate(rom, count)}
      end)

    result
  end

  @doc """
  Converts Roman numerals to Arabic numbers.
  """
  def from_roman(roman) when is_binary(roman) do
    chars = String.graphemes(roman)

    values = %{
      "I" => 1,
      "V" => 5,
      "X" => 10,
      "L" => 50,
      "C" => 100,
      "D" => 500,
      "M" => 1000
    }

    {result, _} =
      Enum.reduce(chars, {0, 0}, fn char, {sum, prev} ->
        current = Map.get(values, char, 0)

        # If current value is greater than previous, subtract twice the previous
        # (we already added it once in the previous iteration)
        if current > prev and prev > 0 do
          {sum - prev * 2 + current, current}
        else
          {sum + current, current}
        end
      end)

    result
  end
end

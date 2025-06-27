defmodule NumberF.I18n do
  @moduledoc """
  Functions for number internationalization and localization.
  """

  @doc """
  Returns locale-specific number formatting settings.

  ## Parameters
    - `locale`: The locale code (e.g., "en-US", "fr-FR")

  ## Examples

      iex> NumberF.I18n.get_locale_settings("en-US")
      %{
        thousands_separator: ",",
        decimal_separator: ".",
        currency_symbol: "$",
        currency_symbol_first: true
      }

      iex> NumberF.I18n.get_locale_settings("fr-FR")
      %{
        thousands_separator: " ",
        decimal_separator: ",",
        currency_symbol: "€",
        currency_symbol_first: false
      }
  """
  def get_locale_settings(locale) do
    Map.get(locale_settings(), locale, Map.get(locale_settings(), "en-US"))
  end

  @doc """
  Formats a number according to locale-specific settings.

  ## Parameters
    - `number`: The number to format
    - `locale`: The locale code (e.g., "en-US", "fr-FR")
    - `options`: Additional formatting options
      - `:precision`: Number of decimal places (default: 2)

  ## Examples

      iex> NumberF.I18n.format_number(1234567.89, "en-US")
      "1,234,567.89"

      iex> NumberF.I18n.format_number(1234567.89, "fr-FR")
      "1 234 567,89"

      iex> NumberF.I18n.format_number(1234567.89, "de-DE", precision: 3)
      "1.234.567,890"
  """
  def format_number(number, locale, options \\ []) when is_number(number) do
    settings = get_locale_settings(locale)
    precision = Keyword.get(options, :precision, 2)

    NumberF.CustomFormatter.number_to_delimited(
      number,
      delimiter: settings.thousands_separator,
      separator: settings.decimal_separator,
      precision: precision
    )
  end

  @doc """
  Formats a number as currency according to locale-specific settings.

  ## Parameters
    - `number`: The number to format
    - `locale`: The locale code (e.g., "en-US", "fr-FR")
    - `options`: Additional formatting options
      - `:precision`: Number of decimal places (default: 2)
      - `:currency_code`: ISO currency code to override the locale default
      - `:symbol`: Whether to include the currency symbol (default: true)

  ## Examples

      iex> NumberF.I18n.format_currency(1234.56, "en-US")
      "$1,234.56"

      iex> NumberF.I18n.format_currency(1234.56, "fr-FR")
      "1 234,56 €"

      iex> NumberF.I18n.format_currency(1234.56, "en-US", currency_code: "EUR")
      "€1,234.56"
  """
  def format_currency(number, locale, options \\ []) when is_number(number) do
    settings = get_locale_settings(locale)
    precision = Keyword.get(options, :precision, 2)
    include_symbol = Keyword.get(options, :symbol, true)

    # Determine currency symbol (from options or locale settings)
    currency_code = Keyword.get(options, :currency_code, nil)

    symbol =
      if currency_code do
        # Get symbol from the specified currency code
        currency_data = NumberF.Currencies.get_currency(currency_code)
        currency_data.symbol
      else
        # Use locale default
        settings.currency_symbol
      end

    # Format number
    formatted_number = format_number(number, locale, precision: precision)

    # Add currency symbol if required
    if include_symbol do
      if settings.currency_symbol_first do
        "#{symbol}#{formatted_number}"
      else
        "#{formatted_number} #{symbol}"
      end
    else
      formatted_number
    end
  end

  @doc """
  Parses a localized number string into a floating-point value.

  ## Parameters
    - `number_string`: The string to parse
    - `locale`: The locale code (e.g., "en-US", "fr-FR")

  ## Examples

      iex> NumberF.I18n.parse_number("1,234.56", "en-US")
      1234.56

      iex> NumberF.I18n.parse_number("1 234,56", "fr-FR")
      1234.56
  """
  def parse_number(number_string, locale) when is_binary(number_string) do
    settings = get_locale_settings(locale)

    # Clean the number string by removing the thousands separator
    cleaned = String.replace(number_string, settings.thousands_separator, "")

    # If decimal separator is not ".", replace it with "."
    normalized =
      if settings.decimal_separator != "." do
        String.replace(cleaned, settings.decimal_separator, ".")
      else
        cleaned
      end

    # Parse to float
    case Float.parse(normalized) do
      {value, _} -> value
      :error -> raise ArgumentError, "Could not parse number: #{number_string}"
    end
  end

  @doc """
  Spells out a number in the specified language.

  ## Parameters
    - `number`: The number to spell out
    - `language`: The language code (e.g., "en", "fr")
    - `options`: Additional options
      - `:capitalize`: Whether to capitalize the first letter (default: true)
      - `:currency`: Whether to add currency names (default: false)
      - `:currency_code`: ISO currency code (default: nil)

  ## Examples

      iex> NumberF.I18n.spell_number(42, "en")
      "Forty-two"

      iex> NumberF.I18n.spell_number(42, "fr")
      "Quarante-deux"

      iex> NumberF.I18n.spell_number(42.75, "en", currency: true, currency_code: "USD")
      "Forty-two dollars and seventy-five cents"
  """
  def spell_number(number, language, options \\ []) do
    capitalize = Keyword.get(options, :capitalize, true)
    currency = Keyword.get(options, :currency, false)
    currency_code = Keyword.get(options, :currency_code, nil)

    # Get spelling function for language
    spelling_function =
      case language do
        "en" -> &spell_number_en/1
        "fr" -> &spell_number_fr/1
        "es" -> &spell_number_es/1
        "de" -> &spell_number_de/1
        # Fallback to English
        _ -> &spell_number_en/1
      end

    # Split into whole and decimal parts
    {whole, decimal} = split_number(number)

    # Generate base spelling
    spelled =
      if currency && currency_code do
        currency_info = get_currency_names(currency_code, language)

        # Format with currency names
        whole_part = spelling_function.(whole)

        if decimal > 0 do
          decimal_str = spelling_function.(decimal)
          "#{whole_part} #{currency_info.main} and #{decimal_str} #{currency_info.sub}"
        else
          "#{whole_part} #{currency_info.main}"
        end
      else
        # Simple number spelling
        if decimal > 0 do
          whole_part = spelling_function.(whole)
          decimal_part = spelling_function.(decimal)
          "#{whole_part} point #{decimal_part}"
        else
          spelling_function.(whole)
        end
      end

    # Apply capitalization if requested
    if capitalize do
      capitalize_first(spelled)
    else
      spelled
    end
  end

  # Helper function to split a number into whole and decimal parts
  defp split_number(number) when is_integer(number), do: {number, 0}

  defp split_number(number) when is_float(number) do
    # Convert to string with high precision to avoid floating point errors
    str = :erlang.float_to_binary(number, decimals: 10)

    # Split into whole and decimal parts
    [whole_str, decimal_str] = String.split(str, ".")

    # Convert back to numbers
    whole = String.to_integer(whole_str)

    # Handle trailing zeros in decimal part
    decimal_str = String.replace_trailing(decimal_str, "0", "")
    decimal = if decimal_str == "", do: 0, else: String.to_integer(decimal_str)

    {whole, decimal}
  end

  # Helper function to capitalize the first letter of a string
  defp capitalize_first(string) when is_binary(string) do
    case String.graphemes(string) do
      [] -> ""
      [first | rest] -> String.upcase(first) <> Enum.join(rest)
    end
  end

  # English number spelling implementation
  defp spell_number_en(0), do: "zero"
  defp spell_number_en(1), do: "one"
  defp spell_number_en(2), do: "two"
  defp spell_number_en(3), do: "three"
  defp spell_number_en(4), do: "four"
  defp spell_number_en(5), do: "five"
  defp spell_number_en(6), do: "six"
  defp spell_number_en(7), do: "seven"
  defp spell_number_en(8), do: "eight"
  defp spell_number_en(9), do: "nine"
  defp spell_number_en(10), do: "ten"
  defp spell_number_en(11), do: "eleven"
  defp spell_number_en(12), do: "twelve"
  defp spell_number_en(13), do: "thirteen"
  defp spell_number_en(14), do: "fourteen"
  defp spell_number_en(15), do: "fifteen"
  defp spell_number_en(16), do: "sixteen"
  defp spell_number_en(17), do: "seventeen"
  defp spell_number_en(18), do: "eighteen"
  defp spell_number_en(19), do: "nineteen"
  defp spell_number_en(20), do: "twenty"
  defp spell_number_en(30), do: "thirty"
  defp spell_number_en(40), do: "forty"
  defp spell_number_en(50), do: "fifty"
  defp spell_number_en(60), do: "sixty"
  defp spell_number_en(70), do: "seventy"
  defp spell_number_en(80), do: "eighty"
  defp spell_number_en(90), do: "ninety"

  defp spell_number_en(n) when n < 0, do: "negative " <> spell_number_en(-n)

  defp spell_number_en(n) when n < 100 do
    tens = div(n, 10) * 10
    units = rem(n, 10)

    if units == 0 do
      spell_number_en(tens)
    else
      "#{spell_number_en(tens)}-#{spell_number_en(units)}"
    end
  end

  defp spell_number_en(n) when n < 1000 do
    hundreds = div(n, 100)
    remainder = rem(n, 100)

    if remainder == 0 do
      "#{spell_number_en(hundreds)} hundred"
    else
      "#{spell_number_en(hundreds)} hundred and #{spell_number_en(remainder)}"
    end
  end

  defp spell_number_en(n) when n < 1_000_000 do
    thousands = div(n, 1000)
    remainder = rem(n, 1000)

    if remainder == 0 do
      "#{spell_number_en(thousands)} thousand"
    else
      "#{spell_number_en(thousands)} thousand #{conjunction_en(remainder)} #{spell_number_en(remainder)}"
    end
  end

  defp spell_number_en(n) when n < 1_000_000_000 do
    millions = div(n, 1_000_000)
    remainder = rem(n, 1_000_000)

    if remainder == 0 do
      "#{spell_number_en(millions)} million"
    else
      "#{spell_number_en(millions)} million #{conjunction_en(remainder)} #{spell_number_en(remainder)}"
    end
  end

  # Helper for English conjunction rules
  defp conjunction_en(n) when n < 100, do: "and"
  defp conjunction_en(_), do: ""

  # French number spelling implementation
  defp spell_number_fr(0), do: "zéro"
  defp spell_number_fr(1), do: "un"
  defp spell_number_fr(2), do: "deux"
  defp spell_number_fr(3), do: "trois"
  defp spell_number_fr(4), do: "quatre"
  defp spell_number_fr(5), do: "cinq"
  defp spell_number_fr(6), do: "six"
  defp spell_number_fr(7), do: "sept"
  defp spell_number_fr(8), do: "huit"
  defp spell_number_fr(9), do: "neuf"
  defp spell_number_fr(10), do: "dix"
  defp spell_number_fr(11), do: "onze"
  defp spell_number_fr(12), do: "douze"
  defp spell_number_fr(13), do: "treize"
  defp spell_number_fr(14), do: "quatorze"
  defp spell_number_fr(15), do: "quinze"
  defp spell_number_fr(16), do: "seize"
  defp spell_number_fr(17), do: "dix-sept"
  defp spell_number_fr(18), do: "dix-huit"
  defp spell_number_fr(19), do: "dix-neuf"
  defp spell_number_fr(20), do: "vingt"
  defp spell_number_fr(30), do: "trente"
  defp spell_number_fr(40), do: "quarante"
  defp spell_number_fr(50), do: "cinquante"
  defp spell_number_fr(60), do: "soixante"
  defp spell_number_fr(70), do: "soixante-dix"
  defp spell_number_fr(80), do: "quatre-vingts"
  defp spell_number_fr(90), do: "quatre-vingt-dix"

  defp spell_number_fr(n) when n < 0, do: "moins " <> spell_number_fr(-n)

  defp spell_number_fr(n) when n < 100 do
    tens = div(n, 10) * 10
    units = rem(n, 10)

    if units == 0 do
      spell_number_fr(tens)
    else
      "#{spell_number_fr(tens)}-#{spell_number_fr(units)}"
    end
  end

  defp spell_number_fr(n) when n < 1000 do
    hundreds = div(n, 100)
    remainder = rem(n, 100)

    if remainder == 0 do
      "#{spell_number_fr(hundreds)} cent"
    else
      "#{spell_number_fr(hundreds)} cent #{spell_number_fr(remainder)}"
    end
  end

  defp spell_number_fr(n) when n < 1_000_000 do
    thousands = div(n, 1000)
    remainder = rem(n, 1000)

    if remainder == 0 do
      "#{spell_number_fr(thousands)} mille"
    else
      "#{spell_number_fr(thousands)} mille #{spell_number_fr(remainder)}"
    end
  end

  # Spanish number spelling implementation
  defp spell_number_es(0), do: "cero"
  defp spell_number_es(1), do: "uno"
  defp spell_number_es(2), do: "dos"
  defp spell_number_es(3), do: "tres"
  defp spell_number_es(4), do: "cuatro"
  defp spell_number_es(5), do: "cinco"
  defp spell_number_es(6), do: "seis"
  defp spell_number_es(7), do: "siete"
  defp spell_number_es(8), do: "ocho"
  defp spell_number_es(9), do: "nueve"
  defp spell_number_es(10), do: "diez"
  defp spell_number_es(11), do: "once"
  defp spell_number_es(12), do: "doce"
  defp spell_number_es(13), do: "trece"
  defp spell_number_es(14), do: "catorce"
  defp spell_number_es(15), do: "quince"
  defp spell_number_es(16), do: "dieciséis"
  defp spell_number_es(17), do: "diecisiete"
  defp spell_number_es(18), do: "dieciocho"
  defp spell_number_es(19), do: "diecinueve"
  defp spell_number_es(20), do: "veinte"
  defp spell_number_es(30), do: "treinta"
  defp spell_number_es(40), do: "cuarenta"
  defp spell_number_es(50), do: "cincuenta"
  defp spell_number_es(60), do: "sesenta"
  defp spell_number_es(70), do: "setenta"
  defp spell_number_es(80), do: "ochenta"
  defp spell_number_es(90), do: "noventa"

  defp spell_number_es(n) when n < 0, do: "menos " <> spell_number_es(-n)

  defp spell_number_es(n) when n < 100 do
    tens = div(n, 10) * 10
    units = rem(n, 10)

    if units == 0 do
      spell_number_es(tens)
    else
      "#{spell_number_es(tens)} y #{spell_number_es(units)}"
    end
  end

  defp spell_number_es(n) when n < 1000 do
    hundreds = div(n, 100)
    remainder = rem(n, 100)

    if remainder == 0 do
      "#{spell_number_es(hundreds)} ciento"
    else
      "#{spell_number_es(hundreds)} ciento #{spell_number_es(remainder)}"
    end
  end

  defp spell_number_es(n) when n < 1_000_000 do
    thousands = div(n, 1000)
    remainder = rem(n, 1000)

    if remainder == 0 do
      "#{spell_number_es(thousands)} mil"
    else
      "#{spell_number_es(thousands)} mil #{spell_number_es(remainder)}"
    end
  end

  # German number spelling implementation
  defp spell_number_de(0), do: "null"
  defp spell_number_de(1), do: "eins"
  defp spell_number_de(2), do: "zwei"
  defp spell_number_de(3), do: "drei"
  defp spell_number_de(4), do: "vier"
  defp spell_number_de(5), do: "fünf"
  defp spell_number_de(6), do: "sechs"
  defp spell_number_de(7), do: "sieben"
  defp spell_number_de(8), do: "acht"
  defp spell_number_de(9), do: "neun"
  defp spell_number_de(10), do: "zehn"
  defp spell_number_de(11), do: "elf"
  defp spell_number_de(12), do: "zwölf"
  defp spell_number_de(13), do: "dreizehn"
  defp spell_number_de(14), do: "vierzehn"
  defp spell_number_de(15), do: "fünfzehn"
  defp spell_number_de(16), do: "sechzehn"
  defp spell_number_de(17), do: "siebzehn"
  defp spell_number_de(18), do: "achtzehn"
  defp spell_number_de(19), do: "neunzehn"
  defp spell_number_de(20), do: "zwanzig"
  defp spell_number_de(30), do: "dreißig"
  defp spell_number_de(40), do: "vierzig"
  defp spell_number_de(50), do: "fünfzig"
  defp spell_number_de(60), do: "sechzig"
  defp spell_number_de(70), do: "siebzig"
  defp spell_number_de(80), do: "achtzig"
  defp spell_number_de(90), do: "neunzig"

  defp spell_number_de(n) when n < 0, do: "minus " <> spell_number_de(-n)

  defp spell_number_de(n) when n < 100 do
    tens = div(n, 10) * 10
    units = rem(n, 10)

    if units == 0 do
      spell_number_de(tens)
    else
      "#{spell_number_de(units)}und#{spell_number_de(tens)}"
    end
  end

  defp spell_number_de(n) when n < 1000 do
    hundreds = div(n, 100)
    remainder = rem(n, 100)

    if remainder == 0 do
      "#{spell_number_de(hundreds)}hundert"
    else
      "#{spell_number_de(hundreds)}hundert#{spell_number_de(remainder)}"
    end
  end

  defp spell_number_de(n) when n < 1_000_000 do
    thousands = div(n, 1000)
    remainder = rem(n, 1000)

    if remainder == 0 do
      "#{spell_number_de(thousands)}tausend"
    else
      "#{spell_number_de(thousands)}tausend#{spell_number_de(remainder)}"
    end
  end

  @doc """
  Returns currency names for different languages.

  ## Parameters
    - `currency_code`: ISO currency code
    - `language`: Language code

  ## Examples

      iex> NumberF.I18n.get_currency_names("USD", "en")
      %{main: "dollars", sub: "cents"}

      iex> NumberF.I18n.get_currency_names("EUR", "fr")
      %{main: "euros", sub: "centimes"}
  """
  def get_currency_names(currency_code, language) do
    # Create a key combining currency and language
    key = "#{currency_code}_#{language}"

    Map.get(currency_names(), key, %{main: "units", sub: "subunits"})
  end

  # Map of locale-specific formatting settings
  defp locale_settings do
    %{
      "en-US" => %{
        thousands_separator: ",",
        decimal_separator: ".",
        currency_symbol: "$",
        currency_symbol_first: true
      },
      "en-GB" => %{
        thousands_separator: ",",
        decimal_separator: ".",
        currency_symbol: "£",
        currency_symbol_first: true
      },
      "fr-FR" => %{
        thousands_separator: " ",
        decimal_separator: ",",
        currency_symbol: "€",
        currency_symbol_first: false
      },
      "de-DE" => %{
        thousands_separator: ".",
        decimal_separator: ",",
        currency_symbol: "€",
        currency_symbol_first: false
      },
      "es-ES" => %{
        thousands_separator: ".",
        decimal_separator: ",",
        currency_symbol: "€",
        currency_symbol_first: false
      },
      "it-IT" => %{
        thousands_separator: ".",
        decimal_separator: ",",
        currency_symbol: "€",
        currency_symbol_first: false
      },
      "ja-JP" => %{
        thousands_separator: ",",
        decimal_separator: ".",
        currency_symbol: "¥",
        currency_symbol_first: true
      },
      "zh-CN" => %{
        thousands_separator: ",",
        decimal_separator: ".",
        currency_symbol: "¥",
        currency_symbol_first: true
      },
      "pt-BR" => %{
        thousands_separator: ".",
        decimal_separator: ",",
        currency_symbol: "R$",
        currency_symbol_first: true
      },
      "ru-RU" => %{
        thousands_separator: " ",
        decimal_separator: ",",
        currency_symbol: "₽",
        currency_symbol_first: false
      },
      "nl-NL" => %{
        thousands_separator: ".",
        decimal_separator: ",",
        currency_symbol: "€",
        currency_symbol_first: false
      },
      "pl-PL" => %{
        thousands_separator: " ",
        decimal_separator: ",",
        currency_symbol: "zł",
        currency_symbol_first: false
      },
      "sv-SE" => %{
        thousands_separator: " ",
        decimal_separator: ",",
        currency_symbol: "kr",
        currency_symbol_first: false
      },
      "tr-TR" => %{
        thousands_separator: ".",
        decimal_separator: ",",
        currency_symbol: "₺",
        currency_symbol_first: true
      },
      "ar-SA" => %{
        thousands_separator: ",",
        decimal_separator: ".",
        currency_symbol: "﷼",
        currency_symbol_first: false
      },
      "hi-IN" => %{
        thousands_separator: ",",
        decimal_separator: ".",
        currency_symbol: "₹",
        currency_symbol_first: true
      },
      "ko-KR" => %{
        thousands_separator: ",",
        decimal_separator: ".",
        currency_symbol: "₩",
        currency_symbol_first: true
      },
      "th-TH" => %{
        thousands_separator: ",",
        decimal_separator: ".",
        currency_symbol: "฿",
        currency_symbol_first: true
      },
      "vi-VN" => %{
        thousands_separator: ".",
        decimal_separator: ",",
        currency_symbol: "₫",
        currency_symbol_first: false
      },
      "id-ID" => %{
        thousands_separator: ".",
        decimal_separator: ",",
        currency_symbol: "Rp",
        currency_symbol_first: true
      },
      "ms-MY" => %{
        thousands_separator: ",",
        decimal_separator: ".",
        currency_symbol: "RM",
        currency_symbol_first: true
      },
      "en-ZM" => %{
        thousands_separator: ",",
        decimal_separator: ".",
        currency_symbol: "K",
        currency_symbol_first: true
      }
    }
  end

  # Map of currency names for different languages
  defp currency_names do
    %{
      "USD_en" => %{main: "dollars", sub: "cents"},
      "USD_fr" => %{main: "dollars", sub: "cents"},
      "USD_es" => %{main: "dólares", sub: "centavos"},
      "USD_de" => %{main: "Dollar", sub: "Cent"},
      "EUR_en" => %{main: "euros", sub: "cents"},
      "EUR_fr" => %{main: "euros", sub: "centimes"},
      "EUR_es" => %{main: "euros", sub: "céntimos"},
      "EUR_de" => %{main: "Euro", sub: "Cent"},
      "GBP_en" => %{main: "pounds", sub: "pence"},
      "GBP_fr" => %{main: "livres", sub: "pence"},
      "GBP_es" => %{main: "libras", sub: "peniques"},
      "GBP_de" => %{main: "Pfund", sub: "Pence"},
      "JPY_en" => %{main: "yen", sub: "sen"},
      "JPY_fr" => %{main: "yens", sub: "sen"},
      "JPY_es" => %{main: "yenes", sub: "sen"},
      "JPY_de" => %{main: "Yen", sub: "Sen"},
      "ZMW_en" => %{main: "kwacha", sub: "ngwee"},
      "ZMW_fr" => %{main: "kwachas", sub: "ngwees"},
      "ZMW_es" => %{main: "kwachas", sub: "ngwees"},
      "ZMW_de" => %{main: "Kwacha", sub: "Ngwee"}
    }
  end
end

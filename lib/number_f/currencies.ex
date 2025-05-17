defmodule NumberF.Currencies do
  @moduledoc """
  Functions and data for handling currency-specific operations and information.
  """

  @doc """
  Returns a map of currency information with ISO codes, symbols, and formatting details.
  """
  def currency_data do
    %{
      "USD" => %{
        name: "US Dollar",
        symbol: "$",
        symbol_first: true,
        symbol_space: false,
        decimal_places: 2,
        thousands_separator: ",",
        decimal_separator: "."
      },
      "EUR" => %{
        name: "Euro",
        symbol: "€",
        symbol_first: false,
        symbol_space: true,
        decimal_places: 2,
        thousands_separator: ".",
        decimal_separator: ","
      },
      "GBP" => %{
        name: "British Pound",
        symbol: "£",
        symbol_first: true,
        symbol_space: false,
        decimal_places: 2,
        thousands_separator: ",",
        decimal_separator: "."
      },
      "JPY" => %{
        name: "Japanese Yen",
        symbol: "¥",
        symbol_first: true,
        symbol_space: false,
        decimal_places: 0,
        thousands_separator: ",",
        decimal_separator: "."
      },
      "ZMW" => %{
        name: "Zambian Kwacha",
        symbol: "K",
        symbol_first: true,
        symbol_space: true,
        decimal_places: 2,
        thousands_separator: ",",
        decimal_separator: "."
      },
      "CNY" => %{
        name: "Chinese Yuan",
        symbol: "¥",
        symbol_first: true,
        symbol_space: false,
        decimal_places: 2,
        thousands_separator: ",",
        decimal_separator: "."
      },
      "INR" => %{
        name: "Indian Rupee",
        symbol: "₹",
        symbol_first: true,
        symbol_space: false,
        decimal_places: 2,
        thousands_separator: ",",
        decimal_separator: "."
      },
      "BTC" => %{
        name: "Bitcoin",
        symbol: "₿",
        symbol_first: true,
        symbol_space: false,
        decimal_places: 8,
        thousands_separator: ",",
        decimal_separator: "."
      },
      "ETH" => %{
        name: "Ethereum",
        symbol: "Ξ",
        symbol_first: true,
        symbol_space: false,
        decimal_places: 18,
        thousands_separator: ",",
        decimal_separator: "."
      }
    }
  end

  @doc """
  Gets currency details for a specific currency code.

  ## Parameters
    - `currency_code`: ISO currency code (e.g., "USD", "EUR")

  ## Examples

      iex> NumberF.Currencies.get_currency("USD")
      %{
        name: "US Dollar",
        symbol: "$",
        symbol_first: true,
        symbol_space: false,
        decimal_places: 2,
        thousands_separator: ",",
        decimal_separator: "."
      }
  """
  def get_currency(currency_code) when is_binary(currency_code) do
    currency_data()
    |> Map.get(currency_code, %{
      name: currency_code,
      symbol: currency_code,
      symbol_first: true,
      symbol_space: true,
      decimal_places: 2,
      thousands_separator: ",",
      decimal_separator: "."
    })
  end

  @doc """
  Formats a number according to the currency's formatting rules.

  ## Parameters
    - `number`: The number to format
    - `currency_code`: ISO currency code (e.g., "USD", "EUR")
    - `options`: Additional formatting options (overrides defaults)

  ## Examples

      iex> NumberF.Currencies.format(1234.56, "USD")
      "$1,234.56"

      iex> NumberF.Currencies.format(1234.56, "EUR")
      "1.234,56 €"

      iex> NumberF.Currencies.format(1234.56, "USD", symbol: false)
      "1,234.56"
  """
  def format(number, currency_code, options \\ []) when is_number(number) do
    currency = get_currency(currency_code)

    # Extract options with defaults from currency data
    symbol = Keyword.get(options, :symbol, true)
    symbol_first = Keyword.get(options, :symbol_first, currency.symbol_first)
    symbol_space = Keyword.get(options, :symbol_space, currency.symbol_space)
    decimal_places = Keyword.get(options, :decimal_places, currency.decimal_places)
    thousands_separator = Keyword.get(options, :thousands_separator, currency.thousands_separator)
    decimal_separator = Keyword.get(options, :decimal_separator, currency.decimal_separator)

    # Format the number
    formatted_number =
      NumberF.number_to_delimited(
        number,
        precision: decimal_places,
        delimiter: thousands_separator,
        separator: decimal_separator
      )

    # Add currency symbol if required
    if symbol do
      space = if symbol_space, do: " ", else: ""

      if symbol_first do
        "#{currency.symbol}#{space}#{formatted_number}"
      else
        "#{formatted_number}#{space}#{currency.symbol}"
      end
    else
      formatted_number
    end
  end

  @doc """
  Converts an amount from one currency to another using exchange rates.

  ## Parameters
    - `amount`: The amount to convert
    - `from_currency`: Source currency code
    - `to_currency`: Target currency code
    - `exchange_rates`: Map of exchange rates (relative to a base currency)
    - `base_currency`: The base currency for the exchange rates (default: "USD")

  ## Examples

      iex> exchange_rates = %{"USD" => 1.0, "EUR" => 0.85, "GBP" => 0.75}
      iex> NumberF.Currencies.convert(100, "USD", "EUR", exchange_rates)
      85.0
  """
  def convert(amount, from_currency, to_currency, exchange_rates, base_currency \\ "USD")
      when is_number(amount) do
    if from_currency == to_currency do
      amount
    else
      from_rate = Map.get(exchange_rates, from_currency)
      to_rate = Map.get(exchange_rates, to_currency)

      if from_rate && to_rate do
        if from_currency == base_currency do
          amount * to_rate
        else
          # Convert through base currency
          amount_in_base = amount / from_rate
          amount_in_base * to_rate
        end
      else
        raise ArgumentError, "Exchange rate not found for #{from_currency} or #{to_currency}"
      end
    end
  end

  @doc """
  Parses a currency string into its numeric value.

  ## Parameters
    - `currency_string`: The currency string to parse
    - `currency_code`: ISO currency code for formatting reference (optional)

  ## Examples

      iex> NumberF.Currencies.parse("$1,234.56")
      1234.56

      iex> NumberF.Currencies.parse("1.234,56 €", "EUR")
      1234.56
  """
  def parse(currency_string, currency_code \\ nil) when is_binary(currency_string) do
    currency = if currency_code, do: get_currency(currency_code), else: nil

    # Remove currency symbol and spaces
    cleaned =
      if currency do
        currency_string
        |> String.replace(currency.symbol, "")
        |> String.trim()
      else
        # Try to remove common currency symbols if no currency_code provided
        currency_string
        |> String.replace(~r/[$€£¥₹₿Ξ]/, "")
        |> String.trim()
      end

    # Determine separators based on currency or fallback to common formats
    decimal_separator = if currency, do: currency.decimal_separator, else: "."
    thousands_separator = if currency, do: currency.thousands_separator, else: ","

    # Remove thousands separators and convert decimal separator to standard "."
    normalized =
      cleaned
      |> String.replace(thousands_separator, "")

    # If decimal separator is not ".", replace it with "."
    normalized =
      if decimal_separator != "." do
        String.replace(normalized, decimal_separator, ".")
      else
        normalized
      end

    # Parse to float
    case Float.parse(normalized) do
      {value, _} -> value
      :error -> raise ArgumentError, "Could not parse currency string: #{currency_string}"
    end
  end
end

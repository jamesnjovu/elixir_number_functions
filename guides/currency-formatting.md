# Currency Formatting with NumberF

This guide covers the comprehensive currency formatting capabilities in NumberF, designed to make financial applications easier to build and maintain.

## Basic Currency Formatting

The `currency/3` function is the most common way to format numbers as currency:

```elixir
NumberF.currency(1234.567)                    # => "ZMW 1,234.57"
NumberF.currency(1234.567, "USD", 2)          # => "USD 1,234.57"
NumberF.currency(1234.567, "$", 2)            # => "$ 1,234.57"
```

The function takes three parameters:
- `number`: The number to format
- `unit`: The currency unit (default: "ZMW")
- `precision`: Decimal places (default: 2)

## Advanced Currency Formatting with Locales

For more sophisticated currency formatting that respects locale conventions, use the `format_currency/3` function:

```elixir
# US Dollar format
NumberF.format_currency(1234.56, "en-US")  
# => "$1,234.56"

# Euro format in French locale
NumberF.format_currency(1234.56, "fr-FR")  
# => "1 234,56 €"

# British Pound format
NumberF.format_currency(1234.56, "en-GB")  
# => "£1,234.56"

# Japanese Yen format
NumberF.format_currency(1234.56, "ja-JP")  
# => "¥1,235"  (Yen typically has 0 decimal places)

# Using a different currency than the locale default
NumberF.format_currency(1234.56, "de-DE", currency_code: "USD")  
# => "1.234,56 $"
```

This function handles:
- Correct decimal and thousands separators for each locale
- Proper currency symbol placement (before or after the number)
- Appropriate spacing between symbol and number
- Default decimal places for each currency

## Custom Currency Formatting

For complete control over currency formatting, use `number_to_delimited/2`:

```elixir
# European style with period as thousands separator and comma as decimal
NumberF.number_to_delimited(1234567.89, delimiter: ".", separator: ",")  
# => "1.234.567,89"

# No thousands separator
NumberF.number_to_delimited(1234567.89, delimiter: "", separator: ".")  
# => "1234567.89"

# Custom precision
NumberF.number_to_delimited(1234567.89, precision: 3)  
# => "1,234,567.890"
```

## Currency Abbreviations

For compact display of large currency values:

```elixir
NumberF.abbreviate_number(1234)               # => "1.2K"
NumberF.abbreviate_number(1234567)            # => "1.2M"
NumberF.abbreviate_number(1234567890)         # => "1.2B"
```

Combined with currency:

```elixir
"$" <> NumberF.abbreviate_number(1234567)     # => "$1.2M"
```

## Working with Currency Information

The `NumberF.Currencies` module provides detailed information about different currencies:

```elixir
# Get information about a specific currency
currency_info = NumberF.get_currency("EUR")
# => %{
#   name: "Euro",
#   symbol: "€",
#   symbol_first: false,
#   symbol_space: true,
#   decimal_places: 2,
#   thousands_separator: ".",
#   decimal_separator: ","
# }

# Format using specific currency rules
NumberF.format_with_currency(1234.56, "EUR")  
# => "1.234,56 €"
```

## Currency Conversion

For currency conversion calculations:

```elixir
# Convert 100 USD to EUR with exchange rates
NumberF.convert_currency(100, 1.0, 0.85)      # => 85.0  (USD to EUR)

# Using with real-time exchange rates (pseudocode)
usd_rate = get_exchange_rate("USD")
eur_rate = get_exchange_rate("EUR")
NumberF.convert_currency(amount, usd_rate, eur_rate)
```

## Internationalization Features

For advanced internationalization, the `NumberF.I18n` module offers:

```elixir
# Get formatting rules for a specific locale
locale_settings = NumberF.I18n.get_locale_settings("fr-FR")
# => %{
#   thousands_separator: " ",
#   decimal_separator: ",",
#   currency_symbol: "€",
#   currency_symbol_first: false
# }

# Parse a localized number string back to a numeric value
NumberF.I18n.parse_number("1 234,56", "fr-FR")  # => 1234.56
```

## Practical Examples

### E-commerce Price Display

```elixir
def display_price(price, user_locale \\ "en-US") do
  NumberF.format_currency(price, user_locale)
end

display_price(29.99)  # => "$29.99" for US users
display_price(29.99, "fr-FR")  # => "29,99 €" for French users
```

### Financial Report Generation

```elixir
def generate_financial_summary(revenue, expenses, profit, locale \\ "en-US") do
  """
  Financial Summary
  ================
  Revenue: #{NumberF.format_currency(revenue, locale)}
  Expenses: #{NumberF.format_currency(expenses, locale)}
  Profit: #{NumberF.format_currency(profit, locale)}
  Profit Margin: #{NumberF.percentage(profit, revenue)}%
  """
end
```

### Multi-currency Invoice

```elixir
def format_invoice_item(amount, original_currency, display_currency, exchange_rates) do
  # Get rates for the currencies
  original_rate = Map.get(exchange_rates, original_currency)
  display_rate = Map.get(exchange_rates, display_currency)
  
  # Convert the amount
  converted_amount = NumberF.convert_currency(amount, original_rate, display_rate)
  
  # Format both for display
  original_formatted = NumberF.format_with_currency(amount, original_currency)
  display_formatted = NumberF.format_with_currency(converted_amount, display_currency)
  
  "#{original_formatted} (#{display_formatted})"
end
```

## Best Practices

1. **Use locale-aware formatting** for user-facing displays to respect cultural conventions
2. **Store raw numbers** in your database, not formatted strings
3. **Format at display time** based on user preferences or locale
4. **Use appropriate precision** - most currencies use 2 decimal places, but some like JPY use 0
5. **Handle nil values** - NumberF.currency returns nil for nil input, which is useful for optional values

Currency formatting is an essential part of any financial application. With NumberF, you have all the tools you need to handle currency values correctly and consistently across your application.
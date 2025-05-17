# Internationalization with NumberF

This guide covers the internationalization (i18n) features of NumberF, which allow you to format numbers according to the conventions of different locales and languages.

## Number Formatting for Different Locales

Different regions format numbers differently, especially regarding:
- Thousands separator (comma, period, space)
- Decimal separator (comma, period)
- Currency symbol placement (before/after the number)
- Currency symbol spacing

The `NumberF.I18n` module handles these differences automatically:

```elixir
# Format a number according to locale conventions
NumberF.format_number(1234567.89, "en-US")      # => "1,234,567.89"
NumberF.format_number(1234567.89, "fr-FR")      # => "1 234 567,89"
NumberF.format_number(1234567.89, "de-DE")      # => "1.234.567,89"
NumberF.format_number(1234567.89, "sv-SE")      # => "1 234 567,89"
```

## Currency Formatting for Different Locales

Currency formatting is even more varied across locales:

```elixir
# US Dollar format (symbol first, no space)
NumberF.format_currency(1234.56, "en-US")       # => "$1,234.56"

# Euro format in French locale (symbol after, with space)
NumberF.format_currency(1234.56, "fr-FR")       # => "1 234,56 €"

# Euro format in German locale
NumberF.format_currency(1234.56, "de-DE")       # => "1.234,56 €"

# British Pound format
NumberF.format_currency(1234.56, "en-GB")       # => "£1,234.56"

# Japanese Yen format (no decimal places)
NumberF.format_currency(1234.56, "ja-JP")       # => "¥1,235"

# Indian Rupee format (with special thousands grouping)
NumberF.format_currency(1234567.89, "hi-IN")    # => "₹12,34,567.89"
```

## Formatting with Specific Currency

You can also format a number with a specific currency, regardless of the locale:

```elixir
# Format with US locale but use Euro currency
NumberF.format_currency(1234.56, "en-US", currency_code: "EUR")  
# => "€1,234.56"

# Format with German locale but use US Dollar
NumberF.format_currency(1234.56, "de-DE", currency_code: "USD")  
# => "1.234,56 $"
```

## Spelling Numbers in Different Languages

NumberF can spell out numbers in different languages:

```elixir
# English
NumberF.spell_number(42, "en")                  # => "Forty-two"

# French
NumberF.spell_number(42, "fr")                  # => "Quarante-deux"

# Spanish
NumberF.spell_number(42, "es")                  # => "Cuarenta y dos"

# German
NumberF.spell_number(42, "de")                  # => "Zweiundvierzig"
```

You can also include currency names:

```elixir
# English with currency
NumberF.spell_number(42.75, "en", currency: true, currency_code: "USD")  
# => "Forty-two dollars and seventy-five cents"

# French with currency
NumberF.spell_number(42.75, "fr", currency: true, currency_code: "EUR")  
# => "Quarante-deux euros et soixante-quinze centimes"
```

## Parsing Localized Number Strings

You can parse number strings formatted according to different locale conventions:

```elixir
# Parse US-formatted number
NumberF.I18n.parse_number("1,234.56", "en-US")    # => 1234.56

# Parse French-formatted number
NumberF.I18n.parse_number("1 234,56", "fr-FR")    # => 1234.56

# Parse German-formatted number
NumberF.I18n.parse_number("1.234,56", "de-DE")    # => 1234.56
```

## Getting Locale Information

If you need to access the formatting rules for a specific locale:

```elixir
# Get locale settings
NumberF.I18n.get_locale_settings("fr-FR")
# => %{
#   thousands_separator: " ",
#   decimal_separator: ",",
#   currency_symbol: "€",
#   currency_symbol_first: false
# }

# Get currency names for a specific currency and language
NumberF.I18n.get_currency_names("USD", "en")
# => %{main: "dollars", sub: "cents"}
```

## Supported Locales

NumberF supports a wide range of locales, including:

**European:**
- English (UK): "en-GB"
- English (US): "en-US"
- French: "fr-FR"
- German: "de-DE"
- Spanish: "es-ES"
- Italian: "it-IT"
- Dutch: "nl-NL"
- Swedish: "sv-SE"
- Portuguese (Portugal): "pt-PT"
- Portuguese (Brazil): "pt-BR"
- Polish: "pl-PL"
- Russian: "ru-RU"

**Asian:**
- Japanese: "ja-JP"
- Chinese (Simplified): "zh-CN"
- Chinese (Traditional): "zh-TW"
- Korean: "ko-KR"
- Thai: "th-TH"
- Vietnamese: "vi-VN"
- Hindi: "hi-IN"

**Middle Eastern:**
- Arabic (Saudi Arabia): "ar-SA"
- Turkish: "tr-TR"

**African:**
- Zambian: "en-ZM"
- South African: "en-ZA"

## Practical Examples

### Multilingual E-commerce Application

```elixir
defmodule Store.ProductView do
  # Display product price based on user's locale
  def display_price(price, user_locale \\ "en-US") do
    NumberF.format_currency(price, user_locale)
  end
  
  # Format product specs with appropriate number formats
  def format_specs(weight_kg, dimensions_cm, user_locale) do
    formatted_weight = NumberF.format_number(weight_kg, user_locale)
    [width, height, depth] = dimensions_cm
    
    formatted_dimensions = 
      dimensions_cm
      |> Enum.map(fn dim -> NumberF.format_number(dim, user_locale) end)
      |> Enum.join(" × ")
      
    %{
      weight: "#{formatted_weight} kg",
      dimensions: "#{formatted_dimensions} cm"
    }
  end
end
```

### International Invoice Generation

```elixir
defmodule Billing.InvoiceGenerator do
  def generate_invoice(items, subtotal, tax_rate, customer_locale) do
    # Calculate values
    tax_amount = subtotal * tax_rate
    total = subtotal + tax_amount
    
    # Format all monetary values according to customer's locale
    formatted_items = Enum.map(items, fn {desc, price} ->
      {desc, NumberF.format_currency(price, customer_locale)}
    end)
    
    formatted_subtotal = NumberF.format_currency(subtotal, customer_locale)
    formatted_tax = NumberF.format_currency(tax_amount, customer_locale)
    formatted_total = NumberF.format_currency(total, customer_locale)
    tax_percentage = NumberF.percentage(tax_rate, 1, 1)
    
    # Generate invoice with proper formatting
    %{
      items: formatted_items,
      subtotal: formatted_subtotal,
      tax_rate: "#{tax_percentage}%",
      tax_amount: formatted_tax,
      total: formatted_total,
      total_in_words: NumberF.spell_number(
        total, 
        get_language_from_locale(customer_locale),
        currency: true, 
        currency_code: get_currency_from_locale(customer_locale)
      )
    }
  end
  
  # Helper to extract language code from locale
  defp get_language_from_locale(locale) do
    [language, _] = String.split(locale, "-")
    language
  end
  
  # Helper to get default currency for locale
  defp get_currency_from_locale("en-US"), do: "USD"
  defp get_currency_from_locale("en-GB"), do: "GBP"
  defp get_currency_from_locale("fr-FR"), do: "EUR"
  defp get_currency_from_locale("de-DE"), do: "EUR"
  defp get_currency_from_locale("ja-JP"), do: "JPY"
  defp get_currency_from_locale("en-ZM"), do: "ZMW"
  defp get_currency_from_locale(_), do: "USD"  # Default
end
```

### Financial Report with Multiple Currencies

```elixir
defmodule Finance.Report do
  def generate_multi_currency_report(amounts, base_currency, target_currencies, exchange_rates) do
    # Get base rate
    base_rate = Map.get(exchange_rates, base_currency)
    
    # For each target currency, convert and format
    currency_rows = Enum.map(target_currencies, fn currency ->
      rate = Map.get(exchange_rates, currency)
      converted = NumberF.convert_currency(amounts.revenue, base_rate, rate)
      
      %{
        currency: currency,
        amount: NumberF.format_currency(converted, "en-US", currency_code: currency),
        exchange_rate: "#{base_currency}/#{currency}: #{rate/base_rate}"
      }
    end)
    
    # Base currency amount
    base = %{
      currency: base_currency,
      amount: NumberF.format_currency(amounts.revenue, "en-US", currency_code: base_currency),
      exchange_rate: "1.0"
    }
    
    [base | currency_rows]
  end
end
```

## Best Practices for Internationalization

1. **Default to user's locale** when possible
2. **Store raw numbers** in your database, not formatted strings
3. **Format at display time** based on user preferences
4. **Test with multiple locales** to ensure proper formatting
5. **Consider right-to-left languages** when designing UI layout
6. **Allow users to override** locale-based defaults when needed

With NumberF's internationalization features, your Elixir applications can provide a consistent, culturally appropriate experience for users around the world.
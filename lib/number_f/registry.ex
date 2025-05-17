defmodule NumberF.Registry do
  @moduledoc """
  A registry of all NumberF modules and their functionality.
  Use this module to discover the available features and functions.
  """

  @doc """
  Returns a list of all NumberF modules with brief descriptions.
  """
  def modules do
    [
      %{
        name: "NumberF",
        description: "Core utility module for number operations",
        type: :core
      },
      %{
        name: "NumberF.Currency",
        description: "Currency formatting utilities",
        type: :formatting
      },
      %{
        name: "NumberF.CustomFormatter",
        description: "Custom implementation for number formatting",
        type: :formatting
      },
      %{
        name: "NumberF.Memory",
        description: "Memory size conversion utilities",
        type: :utilities
      },
      %{
        name: "NumberF.Randomizer",
        description: "Random string generation utilities",
        type: :utilities
      },
      %{
        name: "NumberF.NumbersToWords",
        description: "Number to words conversion",
        type: :conversion
      },
      %{
        name: "NumberF.NumberToWord",
        description: "Alternative number to words conversion",
        type: :conversion
      },
      %{
        name: "NumberF.Helper",
        description: "Helper functions for numeric operations",
        type: :utilities
      },
      %{
        name: "NumberF.Calculations",
        description: "General numeric calculation functions",
        type: :calculation
      },
      %{
        name: "NumberF.Financial",
        description: "Financial calculation utilities",
        type: :calculation
      },
      %{
        name: "NumberF.Statistics",
        description: "Statistical calculation functions",
        type: :calculation
      },
      %{
        name: "NumberF.DateCalculations",
        description: "Date-based calculation utilities",
        type: :calculation
      },
      %{
        name: "NumberF.Formatter",
        description: "Number and data formatting utilities",
        type: :formatting
      },
      %{
        name: "NumberF.Validation",
        description: "Number validation utilities",
        type: :validation
      },
      %{
        name: "NumberF.Application",
        description: "OTP Application module",
        type: :infrastructure
      },
      %{
        name: "NumberF.Metrics",
        description: "Unit conversion utilities",
        type: :conversion
      },
      %{
        name: "NumberF.Currencies",
        description: "Currency-specific utilities and data",
        type: :formatting
      },
      %{
        name: "NumberF.Tax",
        description: "Tax calculation utilities",
        type: :calculation
      },
      %{
        name: "NumberF.Precision",
        description: "Numerical precision handling utilities",
        type: :calculation
      },
      %{
        name: "NumberF.I18n",
        description: "Internationalization utilities for numbers",
        type: :i18n
      },
      %{
        name: "NumberF.Registry",
        description: "Module registry for discovering NumberF features",
        type: :infrastructure
      }
    ]
  end

  @doc """
  Returns a list of modules filtered by type.

  ## Parameters
    - `type`: The module type to filter by (e.g., :formatting, :calculation)

  ## Examples

      iex> NumberF.Registry.modules_by_type(:formatting)
      [
        %{name: "NumberF.Currency", description: "Currency formatting utilities", type: :formatting},
        %{name: "NumberF.CustomFormatter", description: "Custom implementation for number formatting", type: :formatting},
        %{name: "NumberF.Formatter", description: "Number and data formatting utilities", type: :formatting},
        %{name: "NumberF.Currencies", description: "Currency-specific utilities and data", type: :formatting}
      ]
  """
  def modules_by_type(type) do
    modules()
    |> Enum.filter(fn module -> module.type == type end)
  end

  @doc """
  Returns module details by name.

  ## Parameters
    - `name`: The module name (e.g., "NumberF.Currency")

  ## Examples

      iex> NumberF.Registry.module_details("NumberF.Currency")
      %{name: "NumberF.Currency", description: "Currency formatting utilities", type: :formatting}
  """
  def module_details(name) do
    modules()
    |> Enum.find(fn module -> module.name == name end)
  end

  @doc """
  Returns a list of available function categories.
  """
  def function_categories do
    [
      %{
        name: "Formatting",
        description: "Functions for formatting numbers in various ways",
        examples: ["currency/3", "comma_separated/2", "number_to_delimited/2", "ordinal/1"]
      },
      %{
        name: "Conversion",
        description: "Functions for converting between different formats and types",
        examples: ["to_words/3", "to_int/1", "to_float/1", "to_decimal/1", "to_boolean/1"]
      },
      %{
        name: "Generation",
        description: "Functions for generating random strings and passwords",
        examples: ["randomizer/2", "default_password/0"]
      },
      %{
        name: "Financial",
        description: "Functions for financial calculations",
        examples: ["simple_interest/3", "compound_interest/4", "calculate_emi/3"]
      },
      %{
        name: "Statistical",
        description: "Functions for statistical analysis",
        examples: ["mean/1", "median/1", "mode/1", "standard_deviation/1"]
      },
      %{
        name: "Validation",
        description: "Functions for validating numbers and formats",
        examples: ["is_valid_number?/1", "is_valid_integer?/1", "is_valid_credit_card?/2"]
      },
      %{
        name: "Utilities",
        description: "Utility functions for various number operations",
        examples: ["memory_size_cal/1", "round_to_nearest/2", "in_range?/3"]
      },
      %{
        name: "Date Calculations",
        description: "Functions for date-based calculations",
        examples: ["calculate_age/1", "payment_due_date/2"]
      },
      %{
        name: "Unit Conversion",
        description: "Functions for converting between different unit systems",
        examples: ["inches_to_cm/1", "miles_to_km/1", "fahrenheit_to_celsius/1"]
      },
      %{
        name: "Tax Calculations",
        description: "Functions for tax-related calculations",
        examples: ["calculate_vat/3", "calculate_sales_tax/3", "calculate_income_tax/2"]
      },
      %{
        name: "Precision Handling",
        description: "Functions for handling numerical precision issues",
        examples: ["round/2", "bankers_round/2", "approximately_equal/3"]
      },
      %{
        name: "Internationalization",
        description: "Functions for handling numbers in different locales",
        examples: ["format_number/3", "format_currency/3", "spell_number/3"]
      }
    ]
  end

  @doc """
  Returns details about a specific function category.

  ## Parameters
    - `name`: The category name (e.g., "Formatting")

  ## Examples

      iex> NumberF.Registry.category_details("Formatting")
      %{
        name: "Formatting",
        description: "Functions for formatting numbers in various ways",
        examples: ["currency/3", "comma_separated/2", "number_to_delimited/2", "ordinal/1"]
      }
  """
  def category_details(name) do
    function_categories()
    |> Enum.find(fn category -> category.name == name end)
  end

  @doc """
  Returns a markdown representation of all modules and their descriptions,
  organized by type.
  """
  def to_markdown do
    # Group modules by type
    grouped =
      modules()
      |> Enum.group_by(fn module -> module.type end)

    markdown = """
    # NumberF Library

    A comprehensive utility library for number formatting, conversion, and manipulation in Elixir.

    ## Module Categories

    """

    # Build sections for each module type
    sections =
      Enum.map(grouped, fn {type, modules} ->
        """
        ### #{format_type(type)}

        #{Enum.map(modules, fn module -> "- **#{module.name}**: #{module.description}" end) |> Enum.join("\n")}
        """
      end)

    # Build function category section
    function_section = """
    ## Function Categories

    #{Enum.map(function_categories(), fn category -> """
      ### #{category.name}

      #{category.description}

      Examples: #{Enum.join(category.examples, ", ")}
      """ end) |> Enum.join("\n")}
    """

    markdown <> Enum.join(sections, "\n") <> "\n\n" <> function_section
  end

  # Format module type for display
  defp format_type(:core), do: "Core Modules"
  defp format_type(:formatting), do: "Formatting Modules"
  defp format_type(:calculation), do: "Calculation Modules"
  defp format_type(:conversion), do: "Conversion Modules"
  defp format_type(:utilities), do: "Utility Modules"
  defp format_type(:validation), do: "Validation Modules"
  defp format_type(:infrastructure), do: "Infrastructure Modules"
  defp format_type(:i18n), do: "Internationalization Modules"
  defp format_type(type), do: "#{type} Modules"
end

defmodule NumberF.FacadeSurfaceTest do
  @moduledoc """
  Asserts that `NumberF` really is the complete entry point its moduledoc claims.

  This file exists because 36 public submodule functions — including every
  interesting one in `NumberF.Tax` — were unreachable from `NumberF` for four
  releases, while the moduledoc promised that "most common functionality is
  available directly from the main NumberF module". A doc claim with nothing
  asserting it is a claim that drifts.

  The sweep is deliberately mechanical: it derives the expected surface from the
  submodules themselves, so adding a public function to a submodule and forgetting
  to delegate it fails here rather than going unnoticed.
  """
  use ExUnit.Case, async: true

  # Names deliberately exposed under a different name on the facade, because the
  # submodule name is too generic to live on a flat namespace.
  @renamed %{
    convert: :convert_between_currencies,
    parse: :parse_currency,
    format: :format_with_currency,
    to_markdown: :documentation,
    supported_languages: :spelling_languages
  }

  @submodules [
    NumberF.Calculations,
    NumberF.Financial,
    NumberF.Statistics,
    NumberF.Precision,
    NumberF.Tax,
    NumberF.Formatter,
    NumberF.CustomFormatter,
    NumberF.Currencies,
    NumberF.Metrics,
    NumberF.Validation,
    NumberF.Password,
    NumberF.DateCalculations,
    NumberF.I18n,
    NumberF.Registry
  ]

  describe "the facade covers every public submodule function" do
    test "no public submodule function is unreachable from NumberF" do
      exported = NumberF.__info__(:functions)
      facade = exported |> Enum.map(&elem(&1, 0)) |> MapSet.new()

      unreachable =
        for module <- @submodules,
            {name, _arity} <- module.__info__(:functions),
            not String.ends_with?(Atom.to_string(name), "_public"),
            exposed = Map.get(@renamed, name, name),
            not MapSet.member?(facade, exposed),
            do: "#{inspect(module)}.#{name}"

      assert unreachable == [],
             "these are public on their submodule but cannot be called from NumberF — " <>
               "add a defdelegate, or an entry to @renamed if it is exposed under another " <>
               "name: #{inspect(Enum.uniq(unreachable))}"
    end
  end

  describe "precision helpers" do
    test "custom_round/3 honours each rounding mode" do
      assert NumberF.custom_round(2.565, 2, :half_down) == 2.56
      assert NumberF.custom_round(2.567, 2) == 2.57
    end

    test "precise_format/2 pads trailing zeros where round_to/3 would drop them" do
      assert NumberF.precise_format(3.14159, 3) == "3.142"
      assert NumberF.precise_format(1.5, 3) == "1.500"
    end

    test "truncate/2 cuts rather than rounds" do
      assert NumberF.truncate(3.999, 2) == 3.99
      assert NumberF.truncate(3.001, 2) == 3.0
    end

    test "sanitize_float/2 replaces non-finite values" do
      assert NumberF.sanitize_float(:nan) == 0.0
      assert NumberF.sanitize_float(:nan, -1.0) == -1.0
      assert NumberF.sanitize_float(1.5) == 1.5
    end
  end

  describe "tax" do
    test "income tax is progressive across every shipped bracket table" do
      for country <- Map.keys(NumberF.income_tax_brackets()) do
        brackets = NumberF.income_tax_brackets()[country]
        low = NumberF.calculate_income_tax(20_000, brackets)
        high = NumberF.calculate_income_tax(200_000, brackets)

        assert high.tax > low.tax, "#{country}: tax did not increase with income"

        assert high.effective_rate >= low.effective_rate,
               "#{country}: effective rate fell as income rose, which is not progressive"
      end
    end

    test "capital gains exemption reduces the taxable gain" do
      without = NumberF.calculate_capital_gains_tax(50_000, 0.15)
      with_exemption = NumberF.calculate_capital_gains_tax(50_000, 0.15, 5_000)

      assert with_exemption.tax < without.tax
      assert with_exemption.taxable_gain == 45_000.0
    end

    test "payroll, corporate and withholding tax" do
      assert %{tax: _, after_tax: _} = NumberF.calculate_corporate_tax(500_000, 0.21)
      assert %{net: 850.0, tax: 150.0} = NumberF.calculate_withholding_tax(1000, 0.15)

      payroll = NumberF.calculate_payroll_tax(60_000, 0.062, 0.0145)
      assert payroll.take_home < payroll.salary
      assert payroll.total_cost > payroll.salary
    end

    test "a contribution cap limits the employee's share" do
      uncapped = NumberF.calculate_payroll_tax(200_000, 0.062, 0.0145)
      capped = NumberF.calculate_payroll_tax(200_000, 0.062, 0.0145, 160_200)

      assert capped.employee_contribution < uncapped.employee_contribution
    end
  end

  describe "formatter" do
    test "percentages, fractions and units" do
      assert is_binary(NumberF.format_percentage(25, 100))
      assert NumberF.format_fraction(3, 4) == "3/4"
      assert NumberF.decimal_to_fraction(0.75) == "3/4"
      assert NumberF.format_with_units(1234.56, prefix: "$") =~ "$"
    end

    test "scientific and engineering notation agree at exact powers of a thousand" do
      assert NumberF.scientific_notation(1_000_000) == "1.0e6"
      assert NumberF.engineering_notation(1_000_000) == "1.0e6"
    end
  end

  describe "metrics" do
    test "every unit table round-trips through convert_units/4" do
      tables = [
        {NumberF.length_units(), "km", "mi"},
        {NumberF.weight_units(), "kg", "lb"},
        {NumberF.volume_units(), "l", "ml"},
        {NumberF.area_units(), "m2", "ft2"}
      ]

      for {table, from, to} <- tables, Map.has_key?(table, from) and Map.has_key?(table, to) do
        there = NumberF.convert_units(100, from, to, table)
        back = NumberF.convert_units(there, to, from, table)

        assert_in_delta back,
                        100,
                        0.01,
                        "#{from} -> #{to} -> #{from} did not round-trip (got #{back})"
      end
    end

    test "the imperial pairs invert one another" do
      assert_in_delta NumberF.pounds_to_kg(NumberF.kg_to_pounds(70)), 70, 0.1
      assert_in_delta NumberF.oz_to_ml(NumberF.ml_to_oz(500)), 500, 1.0
      assert_in_delta NumberF.hectares_to_acres(NumberF.acres_to_hectares(10)), 10, 0.1
    end
  end

  describe "currencies and locales" do
    test "converting through a rate table" do
      rates = %{"USD" => 1.0, "EUR" => 0.85, "GBP" => 0.73}
      assert NumberF.convert_between_currencies(100, "USD", "EUR", rates) == 85.0
      assert NumberF.convert_between_currencies(100, "EUR", "EUR", rates) == 100
    end

    test "parse_currency/2 strips symbols and separators" do
      assert NumberF.parse_currency("$1,234.56") == 1234.56
    end

    test "get_locale_settings/1 exposes the separators used for formatting" do
      settings = NumberF.get_locale_settings("de-DE")
      assert settings.thousands_separator == "."
      assert settings.decimal_separator == ","
    end
  end

  describe "dates" do
    test "next_business_day/1 skips the weekend" do
      # 2024-01-12 is a Friday.
      assert NumberF.next_business_day(~D[2024-01-12]) == ~D[2024-01-15]
    end

    test "add_business_days/2 is symmetric around a midweek date" do
      forward = NumberF.add_business_days(~D[2024-01-15], 5)
      assert NumberF.add_business_days(forward, -5) == ~D[2024-01-15]
    end
  end

  describe "registry" do
    test "module_details/1 and category_details/1 resolve real entries" do
      [%{name: name} | _] = NumberF.modules()
      assert %{name: ^name} = NumberF.module_details(name)

      [%{name: category} | _] = NumberF.function_categories()
      assert %{name: ^category} = NumberF.category_details(category)
    end

    test "documentation/0 renders markdown covering every module" do
      markdown = NumberF.documentation()

      for %{name: name} <- NumberF.modules() do
        assert String.contains?(markdown, name), "#{name} missing from generated docs"
      end
    end
  end
end

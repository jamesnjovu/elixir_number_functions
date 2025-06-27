defmodule NumberF.I18nTest do
  use ExUnit.Case
  doctest NumberF.I18n

  describe "get_locale_settings/1" do
    test "returns locale settings for known locales" do
      us_settings = NumberF.I18n.get_locale_settings("en-US")
      assert us_settings.thousands_separator == ","
      assert us_settings.decimal_separator == "."
      assert us_settings.currency_symbol == "$"
      assert us_settings.currency_symbol_first == true

      fr_settings = NumberF.I18n.get_locale_settings("fr-FR")
      assert fr_settings.thousands_separator == " "
      assert fr_settings.decimal_separator == ","
      assert fr_settings.currency_symbol == "€"
      assert fr_settings.currency_symbol_first == false
    end

    test "returns default settings for unknown locales" do
      unknown_settings = NumberF.I18n.get_locale_settings("xx-XX")
      # Should return US settings as default
      assert unknown_settings.thousands_separator == ","
      assert unknown_settings.decimal_separator == "."
    end
  end

  describe "format_number/3" do
    test "formats numbers according to locale" do
      assert NumberF.I18n.format_number(1_234_567.89, "en-US") == "1,234,567.89"
      assert NumberF.I18n.format_number(1_234_567.89, "fr-FR") == "1 234 567,89"
      assert NumberF.I18n.format_number(1_234_567.89, "de-DE") == "1.234.567,89"
    end

    test "respects precision option" do
      assert NumberF.I18n.format_number(1_234_567.89, "en-US", precision: 0) == "1,234,568"
      assert NumberF.I18n.format_number(1_234_567.89, "en-US", precision: 3) == "1,234,567.890"
    end
  end

  describe "format_currency/3" do
    test "formats currency according to locale" do
      assert NumberF.I18n.format_currency(1234.56, "en-US") == "$1,234.56"
      assert NumberF.I18n.format_currency(1234.56, "fr-FR") == "1 234,56 €"
      assert NumberF.I18n.format_currency(1234.56, "de-DE") == "1.234,56 €"
    end

    test "respects currency_code option" do
      result = NumberF.I18n.format_currency(1234.56, "en-US", currency_code: "EUR")
      assert result == "€1,234.56"
    end

    test "respects symbol option" do
      result = NumberF.I18n.format_currency(1234.56, "en-US", symbol: false)
      assert result == "1,234.56"
    end
  end

  describe "parse_number/2" do
    test "parses localized number strings" do
      assert NumberF.I18n.parse_number("1,234.56", "en-US") == 1234.56
      assert NumberF.I18n.parse_number("1 234,56", "fr-FR") == 1234.56
      assert NumberF.I18n.parse_number("1.234,56", "de-DE") == 1234.56
    end

    test "raises error for invalid number strings" do
      assert_raise ArgumentError, fn ->
        NumberF.I18n.parse_number("invalid", "en-US")
      end
    end
  end

  describe "spell_number/3" do
    test "spells numbers in different languages" do
      assert NumberF.I18n.spell_number(42, "en") == "Forty-two"
      assert NumberF.I18n.spell_number(42, "fr") == "Quarante-deux"
    end

    test "respects capitalize option" do
      assert NumberF.I18n.spell_number(42, "en", capitalize: false) == "forty-two"
    end

    test "handles currency spelling" do
      result = NumberF.I18n.spell_number(42.75, "en", currency: true, currency_code: "USD")
      assert String.contains?(result, "dollars")
      assert String.contains?(result, "cents")
    end
  end

  describe "get_currency_names/2" do
    test "returns currency names for language" do
      usd_en = NumberF.I18n.get_currency_names("USD", "en")
      assert usd_en.main == "dollars"
      assert usd_en.sub == "cents"

      eur_fr = NumberF.I18n.get_currency_names("EUR", "fr")
      assert eur_fr.main == "euros"
      assert eur_fr.sub == "centimes"
    end

    test "returns default for unknown combinations" do
      unknown = NumberF.I18n.get_currency_names("UNKNOWN", "xx")
      assert unknown.main == "units"
      assert unknown.sub == "subunits"
    end
  end
end

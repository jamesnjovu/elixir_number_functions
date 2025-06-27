defmodule NumberF.I18nEdgeCasesTest do
  use ExUnit.Case

  describe "internationalization edge cases" do
    test "handles unknown locales gracefully" do
      # Should fallback to default (en-US) settings
      unknown_result = NumberF.format_number(1234.56, "xx-YY")
      us_result = NumberF.format_number(1234.56, "en-US")
      assert unknown_result == us_result
    end

    test "handles malformed locale strings" do
      malformed_locales = ["en", "EN-us", "en_US", "english", ""]

      Enum.each(malformed_locales, fn locale ->
        # Should not crash and return some formatted result
        result = NumberF.format_number(1234.56, locale)
        assert is_binary(result)
        assert String.contains?(result, "1234")
      end)
    end

    test "handles very large numbers in different locales" do
      large_number = 1_234_567_890.123

      locales = ["en-US", "fr-FR", "de-DE", "ja-JP", "zh-CN"]

      Enum.each(locales, fn locale ->
        result = NumberF.format_number(large_number, locale)
        assert is_binary(result)
        # Should contain the billions digit
        assert String.contains?(result, "1") and String.contains?(result, "234")
      end)
    end

    test "handles currency formatting for all supported locales" do
      amount = 1234.56

      # Test all locale settings
      locale_settings = [
        "en-US",
        "en-GB",
        "fr-FR",
        "de-DE",
        "es-ES",
        "it-IT",
        "ja-JP",
        "zh-CN",
        "pt-BR",
        "ru-RU",
        "nl-NL",
        "pl-PL",
        "sv-SE",
        "tr-TR",
        "ar-SA",
        "hi-IN",
        "ko-KR",
        "th-TH",
        "vi-VN",
        "id-ID",
        "ms-MY",
        "en-ZM"
      ]

      Enum.each(locale_settings, fn locale ->
        result = NumberF.format_currency(amount, locale)
        assert is_binary(result)
        assert String.length(result) > 0
        # Should contain the amount in some form
        assert String.contains?(result, "1234") or String.contains?(result, "1,234") or
                 String.contains?(result, "1 234")
      end)
    end

    test "handles number parsing for different decimal separators" do
      test_cases = [
        {"1,234.56", "en-US", 1234.56},
        {"1 234,56", "fr-FR", 1234.56},
        {"1.234,56", "de-DE", 1234.56},
        {"1234.56", "en-US", 1234.56},
        {"1234,56", "fr-FR", 1234.56}
      ]

      Enum.each(test_cases, fn {input, locale, expected} ->
        result = NumberF.I18n.parse_number(input, locale)
        assert_in_delta result, expected, 0.01
      end)
    end

    test "handles number spelling in different languages" do
      number = 42

      languages = ["en", "fr", "es", "de"]

      Enum.each(languages, fn language ->
        result = NumberF.spell_number(number, language)
        assert is_binary(result)
        assert String.length(result) > 0
        # Should be capitalized by default
        assert String.match?(result, ~r/^[A-Z]/)
      end)
    end

    test "handles currency names for different language combinations" do
      currencies = ["USD", "EUR", "GBP", "JPY", "ZMW"]
      languages = ["en", "fr", "es", "de"]

      Enum.each(currencies, fn currency ->
        Enum.each(languages, fn language ->
          result = NumberF.I18n.get_currency_names(currency, language)
          assert is_map(result)
          assert Map.has_key?(result, :main)
          assert Map.has_key?(result, :sub)
          assert is_binary(result.main)
          assert is_binary(result.sub)
        end)
      end)
    end
  end
end

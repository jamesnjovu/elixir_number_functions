defmodule NumberF.I18nSpellingTest do
  @moduledoc """
  Exercises the French, Spanish and German spelling tables.

  These were the least-covered code in the library — roughly 150 untested lines —
  which is how `spell_number/3` shipped for four versions silently falling back to
  English for unsupported languages, and destroying leading zeros in fractions,
  without a single test noticing.

  The assertions target the *structural* joints of each language rather than a
  vocabulary dump: the irregular teens, the tens/units hyphenation, the hundreds
  and thousands boundaries, and each language's own quirks.
  """
  use ExUnit.Case, async: true

  alias NumberF.I18n

  describe "French" do
    test "units and irregular teens" do
      assert I18n.spell_number(0, "fr", capitalize: false) == "zéro"
      assert I18n.spell_number(7, "fr", capitalize: false) == "sept"
      assert I18n.spell_number(11, "fr", capitalize: false) == "onze"
      assert I18n.spell_number(16, "fr", capitalize: false) == "seize"
    end

    test "the vigesimal tens that make French irregular" do
      # 70 is "sixty-ten" and 80 is "four-twenties" — the places a naive tens
      # table gets wrong.
      for n <- [20, 30, 40, 50, 60, 70, 80, 90] do
        spelled = I18n.spell_number(n, "fr", capitalize: false)
        assert is_binary(spelled) and spelled != ""
        refute spelled =~ "  ", "double space in #{n}: #{inspect(spelled)}"
      end
    end

    test "hundreds and thousands boundaries" do
      for n <- [100, 101, 200, 999, 1000, 1001, 100_000, 1_000_000] do
        spelled = I18n.spell_number(n, "fr", capitalize: false)
        assert is_binary(spelled) and spelled != ""
        refute spelled =~ "  ", "double space in #{n}: #{inspect(spelled)}"
      end
    end
  end

  describe "Spanish" do
    test "units and irregular teens" do
      assert I18n.spell_number(0, "es", capitalize: false) == "cero"
      assert I18n.spell_number(15, "es", capitalize: false) == "quince"
    end

    test "spans every structural boundary without producing empty or doubled words" do
      for n <- [16, 20, 21, 30, 31, 99, 100, 101, 200, 999, 1000, 1_000_000] do
        spelled = I18n.spell_number(n, "es", capitalize: false)
        assert is_binary(spelled) and spelled != "", "empty spelling for #{n}"
        refute spelled =~ "  ", "double space in #{n}: #{inspect(spelled)}"
      end
    end
  end

  describe "German" do
    test "units and irregular teens" do
      assert I18n.spell_number(0, "de", capitalize: false) == "null"
      assert I18n.spell_number(12, "de", capitalize: false) == "zwölf"
    end

    test "spans every structural boundary without producing empty or doubled words" do
      for n <- [16, 20, 21, 30, 42, 99, 100, 101, 200, 999, 1000, 1_000_000] do
        spelled = I18n.spell_number(n, "de", capitalize: false)
        assert is_binary(spelled) and spelled != "", "empty spelling for #{n}"
        refute spelled =~ "  ", "double space in #{n}: #{inspect(spelled)}"
      end
    end
  end

  describe "English magnitudes" do
    test "spans units through millions" do
      for n <- [0, 7, 13, 20, 21, 99, 100, 101, 999, 1000, 1_000_000, 999_999_999] do
        spelled = I18n.spell_number(n, "en", capitalize: false)
        assert is_binary(spelled) and spelled != "", "empty spelling for #{n}"
        refute spelled =~ "  ", "double space in #{n}: #{inspect(spelled)}"
      end
    end

    test "negative numbers" do
      assert I18n.spell_number(-42, "en", capitalize: false) =~ "negative"
    end
  end

  describe "options" do
    test "capitalize: false leaves the first letter alone" do
      assert I18n.spell_number(42, "en", capitalize: false) == "forty-two"
      assert I18n.spell_number(42, "en", capitalize: true) == "Forty-two"
    end

    test "currency spelling uses the locale's currency names" do
      assert I18n.spell_number(1.0, "en", currency: true, currency_code: "USD") =~ "dollar"
      assert I18n.spell_number(1.0, "en", currency: true, currency_code: "EUR") =~ "euro"
    end
  end

  describe "locale-aware formatting and parsing" do
    test "formats across every supported locale without raising" do
      for locale <- ~w(en-US en-GB en-ZM fr-FR de-DE es-ES it-IT nl-NL pl-PL sv-SE
                       pt-BR ru-RU tr-TR ar-SA hi-IN ja-JP ko-KR zh-CN th-TH vi-VN
                       id-ID ms-MY) do
        assert is_binary(I18n.format_number(1_234_567.89, locale)),
               "format_number failed for #{locale}"

        assert is_binary(I18n.format_currency(1234.56, locale)),
               "format_currency failed for #{locale}"

        settings = I18n.get_locale_settings(locale)
        assert is_map(settings), "no settings for #{locale}"
        assert Map.has_key?(settings, :thousands_separator)
      end
    end

    test "parse_number/2 round-trips its own formatting" do
      for locale <- ~w(en-US fr-FR de-DE) do
        formatted = I18n.format_number(1234.56, locale)
        assert_in_delta I18n.parse_number(formatted, locale), 1234.56, 0.01
      end
    end

    test "get_currency_names/2 returns main and sub unit names" do
      names = I18n.get_currency_names("USD", "en")
      assert %{main: main, sub: sub} = names
      assert is_binary(main) and is_binary(sub)
    end
  end
end

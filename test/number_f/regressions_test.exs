defmodule NumberF.RegressionsTest do
  @moduledoc """
  One test per defect fixed in v0.2.0.

  This file exists because the v0.1.x line shipped a class of bug that no
  per-function test caught: functions that returned a *plausible* wrong answer
  rather than crashing. `spell_number(1.05, "en")` and `spell_number(1.5, "en")`
  both returned "One point five"; `abbreviate_number(-5000)` returned "-5000";
  `combinations/2` returned a float and silently lost precision. Nothing failed
  loudly, so nothing was noticed.

  Every test below names the symptom it prevents and asserts the *distinguishing*
  property, not merely that the call succeeds.
  """
  use ExUnit.Case, async: true

  describe "decimal spelling" do
    # Regression: split_number/1 did String.to_integer("05"), which is 5, so any
    # fraction with a leading zero spelled as though the zero were absent.
    test "a leading zero in the fraction is not swallowed" do
      refute NumberF.I18n.spell_number(1.05, "en") == NumberF.I18n.spell_number(1.5, "en"),
             "1.05 and 1.5 must not spell identically — the leading zero is significant"

      assert NumberF.I18n.spell_number(1.05, "en") == "One point zero five"
      assert NumberF.I18n.spell_number(1.5, "en") == "One point five"
    end

    test "currency minor units read as tenths, not digits" do
      # 42.5 is fifty cents, not five. The fraction is positional.
      assert NumberF.I18n.spell_number(42.5, "en", currency: true, currency_code: "USD") ==
               "Forty-two dollars and fifty cents"

      assert NumberF.I18n.spell_number(42.05, "en", currency: true, currency_code: "USD") ==
               "Forty-two dollars and five cents"
    end

    # Regression: an empty conjunction was interpolated into the middle of a string,
    # so "One thousand  two hundred..." came back with a double space.
    test "no double space where the conjunction is empty" do
      spelled = NumberF.I18n.spell_number(1234, "en")

      refute spelled =~ "  ", "found a double space in: #{inspect(spelled)}"
      assert spelled == "One thousand two hundred and thirty-four"
    end

    # Regression: any unrecognised language silently fell through to English, so
    # 18 of the 22 advertised locales produced confidently wrong output.
    test "an unsupported language raises instead of quietly returning English" do
      assert_raise ArgumentError, ~r/unsupported language/, fn ->
        NumberF.I18n.spell_number(1234, "it")
      end
    end

    test "supported_languages/0 reports only what can actually be spelled" do
      assert NumberF.I18n.supported_languages() == ["de", "en", "es", "fr"]
    end
  end

  describe "magnitude formatting" do
    # Regression: the tier chain stopped at B, so a trillion fell through to the
    # billions branch and rendered as "1.5e3B".
    test "abbreviates above a billion" do
      assert NumberF.abbreviate_number(1_500_000_000_000) == "1.5T"
    end

    # Regression: every guard was `number >= N`, which no negative satisfies.
    test "abbreviates negative numbers" do
      assert NumberF.abbreviate_number(-5000) == "-5.0K"
      assert NumberF.abbreviate_number(-1_234_567) == "-1.2M"
    end

    # Regression: humanize/1 capped at GB and its `bytes < 1024` head matched
    # negatives, so -5 rendered as "-5 B" via the wrong branch.
    test "humanizes byte counts above a gigabyte" do
      assert NumberF.memory_size_cal(5_000_000_000_000) == "4.55 TB"
      assert NumberF.memory_size_cal(2 * 1024 * 1024 * 1024 * 1024 * 1024) == "2.0 PB"
    end
  end

  describe "scientific and engineering notation" do
    # Regression: both functions hardcoded `if abs(number - 0.000123) < 1.0e-10`
    # and returned a canned string, so their own doctests passed while the general
    # algorithm was never exercised for any |n| < 1. The real defect was trunc/1,
    # which rounds toward zero: log10(0.000123) is -3.91, and trunc gives -3.
    test "handles magnitudes below one, which the hardcoded branch was hiding" do
      assert NumberF.Formatter.scientific_notation(0.000123) == "1.23e-4"
      assert NumberF.Formatter.engineering_notation(0.000123) == "123.0e-6"
    end

    test "handles neighbouring values the hardcoded branch never covered" do
      assert NumberF.Formatter.scientific_notation(0.000456) == "4.56e-4"
      assert NumberF.Formatter.scientific_notation(0.0123) == "1.23e-2"
      assert NumberF.Formatter.engineering_notation(0.0456) == "45.6e-3"
    end
  end

  describe "exact integer arithmetic" do
    # Regression: combinations/2 was factorial(n) / (factorial(k) * factorial(n-k)),
    # which is float division — so it returned 155117520.0 and lost precision
    # entirely for larger n.
    test "combinations/2 returns an integer" do
      assert NumberF.combinations(5, 2) === 10
      assert NumberF.combinations(30, 15) === 155_117_520
    end

    test "combinations/2 stays exact well past the float mantissa" do
      assert NumberF.combinations(100, 50) === 100_891_344_545_564_193_334_812_497_256
    end
  end

  describe "statistics" do
    # Regression: only the population form existed, so anyone computing spread for
    # a sample got a silently biased answer with no alternative to reach for.
    test "sample and population variance are both available and differ" do
      data = [2, 4, 4, 4, 5, 5, 7, 9]

      assert NumberF.Statistics.variance(data) == 4.0
      assert NumberF.Statistics.sample_variance(data) == 4.571428571428571
      assert NumberF.Statistics.standard_deviation(data) == 2.0
      assert NumberF.Statistics.sample_standard_deviation(data) == 2.138089935299395
    end
  end

  describe "dates" do
    # Regression: a reversed pair built a descending range (0..-4), which emits a
    # Range deprecation warning at runtime and counted upward anyway.
    test "a reversed date pair yields a negative count, without warning" do
      assert NumberF.business_days_between(~D[2024-01-10], ~D[2024-01-05]) == -4
      assert NumberF.business_days_between(~D[2024-01-05], ~D[2024-01-10]) == 4
    end

    # Regression: the guard was `num_days >= 0`, so asking for three business days
    # *before* a date raised FunctionClauseError.
    test "business days can be subtracted" do
      assert NumberF.DateCalculations.add_business_days(~D[2024-01-15], -3) == ~D[2024-01-10]
      assert NumberF.DateCalculations.add_business_days(~D[2024-01-15], 3) == ~D[2024-01-18]
    end
  end

  describe "the error contract" do
    # Regression: an interest-free loan made both the numerator and (power_term - 1)
    # zero, so the annuity formula raised ArithmeticError on a real product.
    test "a zero-rate loan spreads the principal evenly instead of crashing" do
      assert NumberF.calculate_emi(100_000, 0.0, 12) == 8333.33
    end

    # Regression: to_int/1 called Integer.parse/1 unguarded, so it rejected the very
    # type it returns.
    test "to_int/1 accepts the type it produces" do
      assert NumberF.to_int(12) == 12
      assert NumberF.to_int("123.45") == 123
      assert NumberF.to_int(3.9) == 3
    end

    # Regression: guarded on is_number/1 but called Float.round/2, which needs a float.
    test "round_with_precision/2 accepts integers" do
      assert NumberF.round_with_precision(3, 2) == 3.0
    end

    # Regression: these leaked the raw arithmetic/clause error rather than saying
    # what the caller did wrong.
    test "invalid input raises ArgumentError, never a leaked internal error" do
      assert_raise ArgumentError, fn -> NumberF.percentage(10, 0) end
      assert_raise ArgumentError, fn -> NumberF.compound_interest("invalid", 0.05, 1) end
      assert_raise ArgumentError, fn -> NumberF.simple_interest("invalid", 0.05, 1) end
      assert_raise ArgumentError, fn -> NumberF.calculate_emi("invalid", 0.05, 12) end
      assert_raise ArgumentError, fn -> NumberF.to_int(:nope) end
    end
  end

  describe "the shipped public surface" do
    # Regression: NumbersToWords.try/0 was a debug leftover — public, zero-arity,
    # hardcoded to Decimal.new("2.5") — and shipped in the Hex package.
    test "no debug leftovers are exported" do
      refute function_exported?(NumberF.NumbersToWords, :try, 0),
             "NumbersToWords.try/0 is a debug leftover and must not be public"
    end

    # Regression: :alpha returned letters AND digits, making it identical to the
    # catch-all, so the one option documented as "letters only" never worked.
    test "randomizer/2 :alpha really is letters only" do
      for _ <- 1..20 do
        assert NumberF.randomizer(30, :alpha) =~ ~r/^[A-Za-z]+$/,
               ":alpha must not emit digits"
      end
    end
  end
end

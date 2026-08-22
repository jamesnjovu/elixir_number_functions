defmodule NumberF.V030AdditionsTest do
  @moduledoc """
  Edge cases and invariants for the functions added in v0.3.0.

  The doctests already pin the happy path for each function, so this file
  deliberately does not repeat them. It covers the three things doctests are bad
  at: the error contract, properties that must hold across many inputs, and the
  boundaries where a formula changes shape (a zero rate, an empty list, a value
  that sits exactly on a rounding tie).
  """
  use ExUnit.Case, async: true

  describe "statistics: error contract" do
    test "an empty list yields nil rather than crashing" do
      for fun <- [:percentile, :quartiles, :iqr, :summary, :geometric_mean, :harmonic_mean] do
        result =
          case fun do
            :percentile -> NumberF.percentile([], 50)
            other -> apply(NumberF, other, [[]])
          end

        assert result == nil or result == [], "#{fun}([]) returned #{inspect(result)}"
      end
    end

    test "degenerate inputs raise instead of dividing by zero" do
      assert_raise ArgumentError, fn -> NumberF.z_score(1, 1, 0) end
      assert_raise ArgumentError, fn -> NumberF.z_scores([5, 5, 5]) end
      assert_raise ArgumentError, fn -> NumberF.correlation([1, 1, 1], [1, 2, 3]) end
      assert_raise ArgumentError, fn -> NumberF.coefficient_of_variation([-1, 1]) end
      assert_raise ArgumentError, fn -> NumberF.geometric_mean([1, 0, 4]) end
      assert_raise ArgumentError, fn -> NumberF.percentile([1, 2, 3], 101) end
      assert_raise ArgumentError, fn -> NumberF.weighted_mean([1, 2], [1]) end
      assert_raise ArgumentError, fn -> NumberF.correlation([1, 2], [1]) end
      assert_raise ArgumentError, fn -> NumberF.moving_average([1, 2], 5) end
      assert_raise ArgumentError, fn -> NumberF.trimmed_mean([1, 2], 0.6) end
    end
  end

  describe "statistics: invariants" do
    test "percentiles are monotonic and bracketed by min and max" do
      data = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]

      values = Enum.map([0, 10, 25, 50, 75, 90, 100], &NumberF.percentile(data, &1))

      assert values == Enum.sort(values), "percentiles are not monotonic: #{inspect(values)}"
      assert NumberF.percentile(data, 0) == Enum.min(data)
      assert NumberF.percentile(data, 100) == Enum.max(data)
    end

    test "the quartiles agree with percentile/2 and with iqr/1" do
      data = [1, 2, 3, 4, 5, 6, 7, 8]
      q = NumberF.quartiles(data)

      assert q.q1 == NumberF.percentile(data, 25)
      assert q.q2 == NumberF.median(data)
      assert q.q3 == NumberF.percentile(data, 75)
      assert NumberF.iqr(data) == q.q3 - q.q1
    end

    test "correlation of a list with itself is 1, and with its negation is -1" do
      data = [1, 2, 3, 4, 5]
      negated = Enum.map(data, &(-&1))

      assert_in_delta NumberF.correlation(data, data), 1.0, 1.0e-9
      assert_in_delta NumberF.correlation(data, negated), -1.0, 1.0e-9
    end

    test "regression through exactly collinear points is a perfect fit" do
      xs = [1, 2, 3, 4, 5]
      ys = Enum.map(xs, &(3 * &1 + 7))
      result = NumberF.linear_regression(xs, ys)

      assert_in_delta result.slope, 3.0, 1.0e-9
      assert_in_delta result.intercept, 7.0, 1.0e-9
      assert_in_delta result.r_squared, 1.0, 1.0e-9
    end

    test "normalize maps min to 0 and max to 1, and a flat list to zeros" do
      assert NumberF.normalize([5, 10, 15]) == [0.0, 0.5, 1.0]
      assert NumberF.normalize([7, 7, 7]) == [0.0, 0.0, 0.0]
    end

    test "the three means order themselves harmonic <= geometric <= arithmetic" do
      data = [1.0, 4.0, 9.0, 16.0]

      assert NumberF.harmonic_mean(data) <= NumberF.geometric_mean(data)
      assert NumberF.geometric_mean(data) <= NumberF.mean(data)
    end

    test "weighted_mean with equal weights equals the plain mean" do
      data = [4, 8, 15, 16]
      weights = List.duplicate(1, length(data))

      assert NumberF.weighted_mean(data, weights) == NumberF.mean(data)
    end
  end

  describe "financial" do
    test "present and future value invert one another" do
      assert_in_delta NumberF.present_value(NumberF.future_value(1000, 0.05, 10), 0.05, 10),
                      1000,
                      0.01
    end

    test "npv at the irr is approximately zero" do
      flows = [-1000, 300, 400, 500, 600]
      {:ok, rate} = NumberF.irr(flows)

      assert_in_delta NumberF.npv(rate, flows), 0.0, 0.01
    end

    test "irr reports why it cannot answer rather than guessing" do
      assert NumberF.irr([100, 200, 300]) == {:error, :no_sign_change}
      assert NumberF.irr([-100, -200]) == {:error, :no_sign_change}
    end

    test "an amortization schedule closes at exactly zero and repays the principal" do
      for {principal, rate, term} <- [{100_000, 0.10, 12}, {250_000, 0.045, 360}, {5000, 0.0, 24}] do
        schedule = NumberF.amortization_schedule(principal, rate, term)

        assert length(schedule) == term

        assert List.last(schedule).balance == 0.0,
               "balance did not close for #{principal}@#{rate}x#{term}"

        repaid = schedule |> Enum.map(& &1.principal) |> Enum.sum() |> Float.round(2)

        assert_in_delta repaid,
                        principal,
                        0.01,
                        "principal repaid (#{repaid}) does not match the loan (#{principal})"
      end
    end

    test "an interest-free loan pays only principal" do
      schedule = NumberF.amortization_schedule(1200, 0.0, 12)

      assert Enum.all?(schedule, &(&1.interest == 0.0))
      assert hd(schedule).payment == 100.0
    end

    test "declining-balance depreciation never falls below salvage" do
      schedule = NumberF.depreciation_declining_balance(10_000, 1_000, 5)

      assert Enum.all?(schedule, &(&1.book_value >= 1_000)),
             "book value dropped below salvage: #{inspect(Enum.map(schedule, & &1.book_value))}"
    end

    test "payback period and its failure case" do
      assert NumberF.payback_period(1000, [300, 400, 500]) == {:ok, 2.6}
      assert NumberF.payback_period(10_000, [300, 400]) == {:error, :never_recovered}
    end

    test "zero-rate annuities degenerate to simple division" do
      assert NumberF.annuity_payment(1200, 0.0, 12) == 100.0
      assert NumberF.annuity_present_value(100, 0.0, 12) == 1200.0
      assert NumberF.annuity_future_value(100, 0.0, 12) == 1200.0
    end

    test "invalid inputs raise" do
      assert_raise ArgumentError, fn -> NumberF.roi(100, 0) end
      assert_raise ArgumentError, fn -> NumberF.cagr(0, 100, 5) end
      assert_raise ArgumentError, fn -> NumberF.break_even_point(1000, 10, 10) end
    end
  end

  describe "precision" do
    test "clamp is idempotent and rejects an inverted range" do
      assert NumberF.clamp(NumberF.clamp(42, 0, 10), 0, 10) == 10
      assert_raise ArgumentError, fn -> NumberF.clamp(5, 10, 0) end
    end

    test "the two half-rounding modes differ exactly on ties" do
      # Away-from-zero always rounds a .5 outward; half-even alternates, which is
      # what keeps large batches of money from drifting upward.
      assert NumberF.round_half_away_from_zero(2.5, 0) == 3.0
      assert NumberF.round_half_even(2.5, 0) == 2.0

      assert NumberF.round_half_away_from_zero(3.5, 0) == 4.0
      assert NumberF.round_half_even(3.5, 0) == 4.0

      assert NumberF.round_half_away_from_zero(-2.5, 0) == -3.0
    end

    test "safe_divide only substitutes on a zero denominator" do
      assert NumberF.safe_divide(10, 0) == 0.0
      assert NumberF.safe_divide(10, 0.0) == 0.0
      assert NumberF.safe_divide(10, 0, :none) == :none
      assert NumberF.safe_divide(-10, 4) == -2.5
    end

    test "sign covers all three cases" do
      assert NumberF.sign(-0.001) == -1
      assert NumberF.sign(0) == 0
      assert NumberF.sign(0.001) == 1
    end
  end

  describe "math" do
    test "combinations and permutations relate by k factorial" do
      for {n, k} <- [{5, 2}, {10, 3}, {20, 7}] do
        assert NumberF.permutations(n, k) ==
                 NumberF.combinations(n, k) * NumberF.factorial(k)
      end
    end

    test "prime factors multiply back to the original" do
      for n <- [2, 17, 360, 9973, 123_456] do
        assert Enum.reduce(NumberF.prime_factors(n), 1, &(&1 * &2)) == n
      end
    end

    test "every prime factor is prime" do
      assert Enum.all?(NumberF.prime_factors(123_456), &NumberF.is_prime?/1)
    end

    test "divisors are complete and each divides evenly" do
      divisors = NumberF.divisors(36)

      assert Enum.all?(divisors, &(rem(36, &1) == 0))
      assert Enum.filter(1..36, &(rem(36, &1) == 0)) == divisors
    end

    test "base conversion round-trips across every supported base" do
      for base <- 2..36, n <- [0, 1, 42, 255, 123_456] do
        assert NumberF.from_base(NumberF.to_base(n, base), base) == n,
               "round-trip failed for #{n} in base #{base}"
      end
    end

    test "the named base helpers agree with to_base/2" do
      assert NumberF.to_hex(255) == NumberF.to_base(255, 16)
      assert NumberF.to_binary(5) == NumberF.to_base(5, 2)
      assert NumberF.to_octal(8) == NumberF.to_base(8, 8)
    end

    test "digit helpers agree with one another" do
      assert NumberF.digit_sum(9875) == Enum.sum(NumberF.digits(9875))
      assert NumberF.reverse_number(NumberF.reverse_number(1234)) == 1234
      assert NumberF.palindrome?(NumberF.from_base("0", 10))
    end

    test "perfect_square? stays correct past the float mantissa" do
      big = 94_906_267

      assert NumberF.perfect_square?(big * big)
      refute NumberF.perfect_square?(big * big + 1)
    end

    test "fibonacci is exact well beyond 64 bits" do
      assert NumberF.fibonacci(100) == 354_224_848_179_261_915_075
      assert List.last(NumberF.fibonacci_sequence(10)) == NumberF.fibonacci(9)
    end

    test "invalid input raises" do
      assert_raise ArgumentError, fn -> NumberF.fibonacci(-1) end
      assert_raise ArgumentError, fn -> NumberF.factorial(-1) end
      assert_raise ArgumentError, fn -> NumberF.divisors(0) end
      assert_raise ArgumentError, fn -> NumberF.to_base(10, 40) end
      assert_raise ArgumentError, fn -> NumberF.from_base("ZZ", 2) end
      assert_raise ArgumentError, fn -> NumberF.log_base(10, 1) end
      assert_raise ArgumentError, fn -> NumberF.nth_root(-16, 2) end
    end
  end

  describe "formatting" do
    test "byte scaling reaches every tier in both bases" do
      assert NumberF.format_bytes(999) == "999 B"
      assert NumberF.format_bytes(1_000) == "1.0 kB"
      assert NumberF.format_bytes(1_000_000_000) == "1.0 GB"
      assert NumberF.format_bytes(10 ** 15) == "1.0 PB"
      assert NumberF.format_bytes(1024, base: :binary) == "1.0 KiB"
      assert NumberF.format_bytes(-1_500_000) == "-1.5 MB"
    end

    test "durations render in all three formats, including zero" do
      assert NumberF.format_duration(0) == "0s"
      assert NumberF.format_duration(0, format: :long) == "0 seconds"
      assert NumberF.format_duration(0, format: :clock) == "00:00:00"
      assert NumberF.format_duration(59) == "59s"
      assert NumberF.format_duration(3600) == "1h"
      assert NumberF.format_duration(3600, format: :long) == "1 hour"
    end

    test "significant figures are scale independent" do
      assert NumberF.significant_figures(1_234_567, 3) == 1_230_000.0
      assert NumberF.significant_figures(0.001234567, 3) == 0.00123
      assert NumberF.significant_figures(0, 3) == 0.0
    end

    test "accounting format brackets only the negatives" do
      assert NumberF.accounting_format(-1234.56, unit: "$") == "($1,234.56)"
      assert NumberF.accounting_format(0, unit: "$") == "$0.00"
    end

    test "pluralize handles zero and negatives as plurals" do
      assert NumberF.pluralize(0, "item") == "0 items"
      assert NumberF.pluralize(-1, "item") == "-1 item"
    end

    test "invalid options raise rather than silently defaulting" do
      assert_raise ArgumentError, fn -> NumberF.format_bytes(100, base: :nonsense) end
      assert_raise ArgumentError, fn -> NumberF.format_duration(100, format: :nonsense) end
      assert_raise ArgumentError, fn -> NumberF.pad_number(1, 5, align: :middle) end
    end
  end

  describe "validation" do
    test "rejects malformed input without raising" do
      for fun <- [
            :valid_iban?,
            :valid_isbn?,
            :valid_ean?,
            :valid_upc?,
            :valid_luhn?,
            :valid_routing_number?,
            :valid_imei?,
            :valid_currency_code?
          ] do
        refute apply(NumberF, fun, [""]), "#{fun} accepted an empty string"
        refute apply(NumberF, fun, ["not a number"]), "#{fun} accepted junk"
        refute apply(NumberF, fun, [nil]), "#{fun} accepted nil"
      end
    end

    test "a generated Luhn check digit always validates" do
      for body <- ["411111111111111", "5500000000000", "37828224631000", "1234567890"] do
        full = body <> Integer.to_string(NumberF.luhn_check_digit(body))

        assert NumberF.valid_luhn?(full),
               "#{full} failed validation despite a generated check digit"
      end
    end

    test "card_brand never raises and falls back to :unknown" do
      assert NumberF.card_brand("") == :unknown
      assert NumberF.card_brand("abcd") == :unknown
      assert NumberF.card_brand(nil) == :unknown
      assert NumberF.card_brand("6011000000000004") == :discover
    end

    test "percentage bounds are inclusive" do
      assert NumberF.valid_percentage?(0)
      assert NumberF.valid_percentage?(100)
      refute NumberF.valid_percentage?(-0.1)
      refute NumberF.valid_percentage?(100.1)
    end
  end

  describe "dates" do
    test "quarters partition the year and their bounds are consistent" do
      for month <- 1..12 do
        date = Date.new!(2024, month, 15)
        q = NumberF.quarter(date)

        assert q in 1..4
        assert NumberF.quarter_start(date).month == (q - 1) * 3 + 1
        assert NumberF.quarter_end(date).month == q * 3
        assert Date.compare(NumberF.quarter_start(date), date) in [:lt, :eq]
        assert Date.compare(NumberF.quarter_end(date), date) in [:gt, :eq]
      end
    end

    test "month bounds match the calendar, including February in a leap year" do
      assert NumberF.month_end(~D[2024-02-10]) == ~D[2024-02-29]
      assert NumberF.month_end(~D[2023-02-10]) == ~D[2023-02-28]
      assert NumberF.month_start(~D[2024-02-10]) == ~D[2024-02-01]
    end

    test "leap years follow the full Gregorian rule, not just divisibility by four" do
      assert NumberF.leap_year?(2024)
      assert NumberF.leap_year?(2000)
      refute NumberF.leap_year?(1900)
      refute NumberF.leap_year?(2023)
    end

    test "the fiscal year rolls over at the configured start month" do
      assert NumberF.fiscal_year(~D[2024-03-31], 4) == 2024
      assert NumberF.fiscal_year(~D[2024-04-01], 4) == 2025
      assert NumberF.fiscal_year(~D[2024-06-15], 1) == 2025
    end

    test "age_in_months does not count a birthday that has not arrived" do
      assert NumberF.age_in_months(~D[2020-01-15], ~D[2024-01-14]) == 47
      assert NumberF.age_in_months(~D[2020-01-15], ~D[2024-01-15]) == 48
    end
  end
end

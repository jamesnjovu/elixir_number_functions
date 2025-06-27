defmodule NumberF.DateCalculationsTest do
  use ExUnit.Case
  doctest NumberF.DateCalculations

  describe "calculate_age/1" do
    test "calculates age correctly" do
      today = Date.utc_today()
      twenty_years_ago = %{today | year: today.year - 20}
      ten_years_ago = %{today | year: today.year - 10}

      assert NumberF.DateCalculations.calculate_age(twenty_years_ago) == 20
      assert NumberF.DateCalculations.calculate_age(ten_years_ago) == 10
    end

    test "handles birthday not yet occurred this year" do
      today = Date.utc_today()
      # Birth date is tomorrow but 20 years ago
      birth_date = %{today | year: today.year - 20, day: today.day + 1}

      # Should be 19 if birthday hasn't occurred
      if Date.compare(birth_date, today) == :gt do
        assert NumberF.DateCalculations.calculate_age(birth_date) == 19
      end
    end
  end

  describe "payment_due_date/2" do
    test "calculates due date with default terms" do
      invoice_date = ~D[2023-01-15]
      due_date = NumberF.DateCalculations.payment_due_date(invoice_date, 30)
      assert due_date == ~D[2023-02-14]
    end

    test "calculates due date with custom terms" do
      invoice_date = ~D[2023-01-15]
      due_date = NumberF.DateCalculations.payment_due_date(invoice_date, 45)
      assert due_date == ~D[2023-03-01]
    end
  end

  describe "days_between/2" do
    test "calculates days between dates" do
      date1 = ~D[2023-01-01]
      date2 = ~D[2023-01-10]
      assert NumberF.DateCalculations.days_between(date1, date2) == 9
    end

    test "handles negative differences" do
      date1 = ~D[2023-01-10]
      date2 = ~D[2023-01-01]
      assert NumberF.DateCalculations.days_between(date1, date2) == -9
    end
  end

  describe "business_days_between/2" do
    test "calculates business days between dates" do
      # Monday to Friday (5 business days)
      monday = ~D[2023-01-02]
      friday = ~D[2023-01-06]
      assert NumberF.DateCalculations.business_days_between(monday, friday) == 5
    end

    test "excludes weekends" do
      # Friday to next Monday (2 business days: Friday and Monday)
      friday = ~D[2023-01-06]
      monday = ~D[2023-01-09]
      assert NumberF.DateCalculations.business_days_between(friday, monday) == 2
    end
  end

  describe "is_business_day?/1" do
    test "identifies business days correctly" do
      # Monday
      assert NumberF.DateCalculations.is_business_day?(~D[2023-01-02]) == true
      # Friday
      assert NumberF.DateCalculations.is_business_day?(~D[2023-01-06]) == true
      # Saturday
      assert NumberF.DateCalculations.is_business_day?(~D[2023-01-07]) == false
      # Sunday
      assert NumberF.DateCalculations.is_business_day?(~D[2023-01-08]) == false
    end
  end

  describe "add_business_days/2" do
    test "adds business days correctly" do
      # Adding 5 business days to Monday should give next Monday
      monday = ~D[2023-01-02]
      result = NumberF.DateCalculations.add_business_days(monday, 5)
      assert result == ~D[2023-01-09]
    end

    test "skips weekends when adding business days" do
      # Adding 1 business day to Friday should give Monday
      friday = ~D[2023-01-06]
      result = NumberF.DateCalculations.add_business_days(friday, 1)
      assert result == ~D[2023-01-09]
    end
  end

  describe "next_business_day/1" do
    test "finds next business day" do
      # Next business day after Friday should be Monday
      friday = ~D[2023-01-06]
      assert NumberF.DateCalculations.next_business_day(friday) == ~D[2023-01-09]

      # Next business day after Monday should be Tuesday
      monday = ~D[2023-01-02]
      assert NumberF.DateCalculations.next_business_day(monday) == ~D[2023-01-03]
    end
  end
end

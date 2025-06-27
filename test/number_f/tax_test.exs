defmodule NumberF.TaxTest do
  use ExUnit.Case
  doctest NumberF.Tax

  describe "calculate_vat/3" do
    test "calculates VAT for exclusive amount" do
      result = NumberF.Tax.calculate_vat(100, 0.2)

      assert result.net == 100.0
      assert result.vat == 20.0
      assert result.gross == 120.0
    end

    test "calculates VAT for inclusive amount" do
      result = NumberF.Tax.calculate_vat(120, 0.2, true)

      assert result.net == 100.0
      assert result.vat == 20.0
      assert result.gross == 120.0
    end
  end

  describe "calculate_sales_tax/3" do
    test "calculates sales tax" do
      result = NumberF.Tax.calculate_sales_tax(100, 0.06)

      assert result.subtotal == 100.0
      assert result.tax == 6.0
      assert result.total == 106.0
    end

    test "calculates sales tax with custom rounding" do
      result = NumberF.Tax.calculate_sales_tax(100, 0.0625, round_to: 0.05)

      assert result.subtotal == 100.0
      assert result.tax == 6.25
      assert result.total == 106.25
    end
  end

  describe "calculate_income_tax/2" do
    test "calculates progressive income tax" do
      brackets = [{0, 0.0}, {12570, 0.2}, {50270, 0.4}, {150_000, 0.45}]

      result = NumberF.Tax.calculate_income_tax(30000, brackets)

      assert result.tax == 3486.0
      assert result.effective_rate == 0.1162
    end

    test "handles income below first bracket" do
      brackets = [{0, 0.0}, {10000, 0.1}]

      result = NumberF.Tax.calculate_income_tax(5000, brackets)

      assert result.tax == 0.0
      assert result.effective_rate == 0.0
    end
  end

  describe "vat_rates/0" do
    test "returns VAT rates for different countries" do
      rates = NumberF.Tax.vat_rates()

      assert rates["UK"] == 0.2
      assert rates["Germany"] == 0.19
      assert rates["Zambia"] == 0.16
    end
  end

  describe "calculate_withholding_tax/2" do
    test "calculates withholding tax" do
      result = NumberF.Tax.calculate_withholding_tax(1000, 0.15)

      assert result.gross == 1000.0
      assert result.tax == 150.0
      assert result.net == 850.0
    end
  end

  describe "calculate_corporate_tax/2" do
    test "calculates corporate tax" do
      result = NumberF.Tax.calculate_corporate_tax(100_000, 0.19)

      assert result.profit == 100_000.0
      assert result.tax == 19000.0
      assert result.after_tax == 81000.0
    end
  end

  describe "calculate_capital_gains_tax/3" do
    test "calculates capital gains tax with exemption" do
      result = NumberF.Tax.calculate_capital_gains_tax(20000, 0.2, 12300)

      assert result.gain == 20000.0
      assert result.taxable_gain == 7700.0
      assert result.tax == 1540.0
      assert result.net == 18460.0
    end

    test "handles gain below exemption" do
      result = NumberF.Tax.calculate_capital_gains_tax(10000, 0.2, 12300)

      assert result.gain == 10000.0
      assert result.taxable_gain == 0.0
      assert result.tax == 0.0
      assert result.net == 10000.0
    end
  end

  describe "calculate_payroll_tax/4" do
    test "calculates payroll tax without cap" do
      result = NumberF.Tax.calculate_payroll_tax(50000, 0.12, 0.138)

      assert result.salary == 50000.0
      assert result.employee_contribution == 6000.0
      assert result.employer_contribution == 6900.0
      assert result.total_cost == 56900.0
      assert result.take_home == 44000.0
    end

    test "calculates payroll tax with cap" do
      result = NumberF.Tax.calculate_payroll_tax(200_000, 0.12, 0.138, 100_000)

      assert result.salary == 200_000.0
      # Based on cap
      assert result.employee_contribution == 12000.0
      # Based on cap
      assert result.employer_contribution == 13800.0
    end
  end
end

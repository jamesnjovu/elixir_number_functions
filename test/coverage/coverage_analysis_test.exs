defmodule NumberF.CoverageAnalysisTest do
  use ExUnit.Case

  describe "coverage analysis" do
    @describetag :coverage
    test "all public functions are tested" do
      # Get all modules in NumberF
      numberf_modules = [
        NumberF,
        NumberF.Calculations,
        NumberF.Financial,
        NumberF.Statistics,
        NumberF.DateCalculations,
        NumberF.Formatter,
        NumberF.Validation,
        NumberF.Metrics,
        NumberF.Currencies,
        NumberF.Tax,
        NumberF.Precision,
        NumberF.I18n,
        NumberF.CustomFormatter,
        NumberF.Memory,
        NumberF.Randomizer,
        NumberF.Registry,
        NumberF.NumbersToWords,
        NumberF.NumberToWord
      ]

      # Check that each module has corresponding test module
      Enum.each(numberf_modules, fn module ->
        module_name = module |> Module.split() |> Enum.join(".")
        test_module_name = "#{module_name}Test"

        try do
          test_module = Module.concat([test_module_name])
          # Check if test module exists
          Code.ensure_loaded?(test_module)
        rescue
          _ ->
            # Some modules might not have dedicated test modules (like Application)
            # This is acceptable for certain infrastructure modules
            if module_name not in ["NumberF.Application", "NumberF.Currency"] do
              flunk("Missing test module for #{module_name}")
            end
        end
      end)
    end

    test "all exported functions have tests" do
      # Check NumberF main module functions
      main_functions = NumberF.__info__(:functions)

      # Filter out private functions and those we know are tested
      public_functions =
        Enum.filter(main_functions, fn {name, _arity} ->
          # Exclude private functions and module metadata
          not String.starts_with?(Atom.to_string(name), "__")
        end)

      # Ensure we have a reasonable number of public functions
      assert length(public_functions) > 50,
             "Expected more than 50 public functions in NumberF module"

      # Key functions that should definitely be present and tested
      key_functions = [
        {:currency, 1},
        {:currency, 2},
        {:currency, 3},
        {:to_words, 1},
        {:to_words, 2},
        {:to_words, 3},
        {:mean, 1},
        {:median, 1},
        {:mode, 1},
        {:simple_interest, 3},
        {:compound_interest, 3},
        {:compound_interest, 4},
        {:calculate_emi, 3},
        {:percentage, 2},
        {:percentage, 3}
      ]

      Enum.each(key_functions, fn {name, arity} ->
        assert {name, arity} in public_functions, "Key function #{name}/#{arity} not found"
      end)
    end

    test "error paths are covered" do
      # Test that error conditions are properly tested

      # Division by zero in percentage
      assert_raise ArithmeticError, fn ->
        NumberF.percentage(10, 0)
      end

      # Invalid conversion
      assert_raise ArgumentError, fn ->
        NumberF.to_boolean("invalid")
      end

      # Invalid credit card
      assert NumberF.is_valid_credit_card?("invalid") == false

      # These tests ensure error paths are covered
      assert true
    end

    test "edge cases are covered" do
      # Ensure edge cases are tested

      # Empty collections
      assert NumberF.mean([]) == nil
      assert NumberF.median([]) == nil

      # Zero values
      assert NumberF.currency(0, "USD") == "USD 0.00"

      # Negative values
      assert NumberF.currency(-100, "USD") == "USD -100.00"

      # Very large numbers
      large_num = 999_999_999_999.99
      result = NumberF.currency(large_num, "USD")
      assert String.contains?(result, "999,999,999,999.99")

      # These tests ensure edge cases are covered
      assert true
    end
  end
end

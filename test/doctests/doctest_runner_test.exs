defmodule NumberF.DoctestRunnerTest do
  use ExUnit.Case

  # Run doctests for all modules
  doctest NumberF
  doctest NumberF.Calculations
  doctest NumberF.Financial
  doctest NumberF.Statistics
  doctest NumberF.DateCalculations
  doctest NumberF.Formatter
  doctest NumberF.Validation
  doctest NumberF.Metrics
  doctest NumberF.Currencies
  doctest NumberF.Tax
  doctest NumberF.Precision
  doctest NumberF.I18n
  doctest NumberF.CustomFormatter
  doctest NumberF.Memory
  doctest NumberF.Randomizer
  doctest NumberF.Registry
  doctest NumberF.NumbersToWords
  doctest NumberF.NumberToWord

  test "all modules have proper documentation" do
    modules = [
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
      NumberF.Registry
    ]

    Enum.each(modules, fn module ->
      {:docs_v1, _, _, _, module_doc, _, _} = Code.fetch_docs(module)

      # Each module should have documentation
      assert module_doc != :none, "Module #{module} is missing documentation"

      # Module documentation should not be empty
      case module_doc do
        %{"en" => doc_content} ->
          assert String.length(doc_content) > 10,
                 "Module #{module} has insufficient documentation"

        _ ->
          # Skip if no English docs found (some modules might be internal)
          :ok
      end
    end)
  end
end

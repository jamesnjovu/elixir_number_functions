defmodule NumberF.Currency do
  @moduledoc false

  def currency(value, _unit, _precision) when is_nil(value), do: value

  def currency(value, unit, precision) do
    to_string(value)
    |> Number.Currency.number_to_currency(unit: unit, precision: precision)
  end

  def comma_separated(value, _precision) when is_nil(value), do: value

  def comma_separated(value, precision) do
    to_string(value)
    |> Number.Currency.number_to_currency(unit: "", precision: precision)
  end
end

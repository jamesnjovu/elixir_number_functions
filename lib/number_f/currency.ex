defmodule NumberF.Currency do
  @moduledoc false
  def currency(value, _unit, _precision) when is_nil(value), do: value

  def currency(value, unit, precision),
    do: NumberF.CustomFormatter.number_to_currency(value, unit: unit, precision: precision)

  def comma_separated(value, _precision) when is_nil(value), do: value

  def comma_separated(value, precision),
    do: NumberF.CustomFormatter.number_to_currency(value, unit: "", precision: precision)
end

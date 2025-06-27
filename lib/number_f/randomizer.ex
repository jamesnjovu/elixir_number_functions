defmodule NumberF.Randomizer do
  @moduledoc false

  def gen_password,
    do: String.capitalize(randomizer(3, :downcase)) <> "@" <> randomizer(4, :numeric)

  def randomizer(length, type) do
    uppercase = "ABCDEFGHJKMNPQRSTUVWXYZ"
    lowercase = "abcdefghjklmnpqrstuvwxyz"
    numbers = "23456789"

    lists =
      cond do
        type == :alpha -> uppercase <> lowercase <> numbers
        type == :numeric -> numbers
        type == :upcase -> uppercase
        type == :downcase -> lowercase
        true -> uppercase <> lowercase <> numbers
      end
      |> String.split("", trim: true)

    do_randomizer(length, lists)
  end

  @doc false
  defp get_range(length) when length > 1, do: 1..length
  defp get_range(_length), do: [1]

  @doc false
  defp do_randomizer(length, lists) do
    get_range(length)
    |> Enum.reduce([], fn _, acc -> [Enum.random(lists) | acc] end)
    |> Enum.join("")
  end
end

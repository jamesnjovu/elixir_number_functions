defmodule NumberF.Randomizer do
  @moduledoc false

  def gen_password,
    do: String.capitalize(randomizer(3, :downcase)) <> "@" <> randomizer(4, :numeric)

  # Visually ambiguous characters are excluded on purpose: I/l/1 and O/0 are the
  # pairs people mistype when reading a generated password aloud or off a screen.
  @uppercase "ABCDEFGHJKMNPQRSTUVWXYZ"
  @lowercase "abcdefghjklmnpqrstuvwxyz"
  @numbers "23456789"

  def randomizer(length, type) do
    # :alpha previously returned letters AND digits, making it identical to the
    # catch-all — so the one option documented as "letters only" never worked.
    alphabet =
      case type do
        :alpha -> @uppercase <> @lowercase
        :numeric -> @numbers
        :upcase -> @uppercase
        :downcase -> @lowercase
        _all -> @uppercase <> @lowercase <> @numbers
      end

    do_randomizer(length, String.split(alphabet, "", trim: true))
  end

  defp get_range(length) when length > 1, do: 1..length
  defp get_range(_length), do: [1]

  defp do_randomizer(length, alphabet) do
    length
    |> get_range()
    |> Enum.map_join("", fn _ -> Enum.random(alphabet) end)
  end
end

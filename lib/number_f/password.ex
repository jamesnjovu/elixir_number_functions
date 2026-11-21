defmodule NumberF.Password do
  @moduledoc """
  Policy-driven password generation and checking.

  One policy drives both sides: `generate_password/1` builds a password that
  satisfies it, and `validate_password/2` checks a password someone typed against
  the same rules, returning the reasons it fails so a form can say what to fix.
  `is_valid_password?/2` is the boolean form.

  ## Policy

  A keyword list. Every key is optional.

  | Key | Default | Meaning |
  |---|---|---|
  | `:min_length` | `12` | Minimum length, in graphemes |
  | `:max_length` | `nil` | Maximum length; `nil` means no cap |
  | `:uppercase` | `1` | Minimum uppercase letters |
  | `:lowercase` | `1` | Minimum lowercase letters |
  | `:digits` | `1` | Minimum digits |
  | `:special` | `1` | Minimum special characters |
  | `:special_chars` | `"!@#$%^&*-_=+?"` | Alphabet the generator draws specials from |
  | `:exclude_ambiguous` | `true` | Generator leaves out `I`, `l`, `1`, `O` and `0` |

  A class minimum of `0` means "not required": the checker accepts that class if it
  is present, and the generator leaves it out entirely. A generated password is
  `max(min_length, sum of the class minimums)` long.

  When checking, uppercase, lowercase and digits are the Unicode classes `Lu`, `Ll`
  and `Nd`. A special character is anything that is neither a letter nor a digit,
  so a user who types `~` is not rejected just because `~` is not in
  `:special_chars`. `:special_chars` and `:exclude_ambiguous` only shape generation.

  An invalid policy raises `ArgumentError` naming the offending key.

  ## Randomness

  Generation draws from `:crypto` (OpenSSL's cryptographically secure generator),
  never from the default `:rand` algorithm. The `:crypto` state is
  threaded explicitly, so the calling process's `:rand` seed is never read or
  changed.

  ## Examples

      iex> NumberF.Password.validate_password("Tr0ub4dor&3")
      {:error, [:too_short]}

      iex> NumberF.Password.validate_password("Tr0ub4dor&3", min_length: 8)
      :ok
  """

  @defaults %{
    min_length: 12,
    max_length: nil,
    uppercase: 1,
    lowercase: 1,
    digits: 1,
    special: 1,
    special_chars: "!@#$%^&*-_=+?",
    exclude_ambiguous: true
  }

  @policy_keys Map.keys(@defaults)

  # The order in which the classes are reported and drawn. Fixed, so the reasons in
  # `{:error, reasons}` always come back in the same order for the same failures.
  @classes [:uppercase, :lowercase, :digits, :special]

  @uppercase "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  @lowercase "abcdefghijklmnopqrstuvwxyz"
  @digits "0123456789"

  # I/l/1 and O/0 are the pairs people misread when copying a password off a
  # screen or reading it aloud. These sets are kept apart from NumberF.Randomizer's
  # because those always leave out a slightly different group (I L O i o 0 1), so
  # they cannot serve `exclude_ambiguous: false`, and changing them would change
  # what randomizer/2 returns.
  @ambiguous ~w(I l 1 O 0)

  @doc """
  Generates a random password that satisfies `policy`.

  See the moduledoc for the policy keys and their defaults.

  ## Examples

      iex> password = NumberF.Password.generate_password()
      iex> String.length(password)
      12

      iex> policy = [min_length: 16, uppercase: 2, digits: 3]
      iex> NumberF.Password.generate_password(policy) |> NumberF.Password.validate_password(policy)
      :ok

      iex> password = NumberF.Password.generate_password(min_length: 6, special: 0, uppercase: 0)
      iex> String.match?(password, ~r/^[a-z0-9]{6}$/)
      true
  """
  def generate_password(policy \\ []) do
    policy = normalise_policy!(policy)
    alphabets = alphabets(policy)
    enabled = Enum.filter(@classes, &(policy[&1] > 0))
    pool = enabled |> Enum.map(&alphabets[&1]) |> merge_alphabets()

    # One slot per character, each holding the alphabet it draws from: the class
    # minimums first, then filler from every class the policy requires.
    required = Enum.flat_map(enabled, &List.duplicate(alphabets[&1], policy[&1]))
    filler = List.duplicate(pool, generated_length(policy) - length(required))

    {chars, state} = Enum.map_reduce(required ++ filler, :crypto.rand_seed_s(), &pick/2)
    {shuffled, _state} = shuffle(chars, state)

    Enum.join(shuffled)
  end

  @doc """
  Checks `password` against `policy`, returning `:ok` or `{:error, reasons}`.

  `reasons` is a list drawn from `:too_short`, `:too_long`, `:too_few_uppercase`,
  `:too_few_lowercase`, `:too_few_digits` and `:too_few_special`, always in that
  order. Raises `ArgumentError` if `password` is not a string.

  ## Examples

      iex> NumberF.Password.validate_password("Correct-Horse-7")
      :ok

      iex> NumberF.Password.validate_password("short")
      {:error, [:too_short, :too_few_uppercase, :too_few_digits, :too_few_special]}

      iex> NumberF.Password.validate_password("Abcdefgh1!", min_length: 6, max_length: 8)
      {:error, [:too_long]}
  """
  def validate_password(password, policy \\ []) do
    policy = normalise_policy!(policy)

    unless is_binary(password) do
      raise ArgumentError,
            "validate_password expects password to be a string, got: #{inspect(password)}"
    end

    case violations(password, policy) do
      [] -> :ok
      reasons -> {:error, reasons}
    end
  end

  @doc """
  Whether `password` satisfies `policy`.

  Returns `false`, rather than raising, for anything that is not a string. An
  invalid `policy` still raises, because that is a bug in the caller rather than
  bad input from a user.

  ## Examples

      iex> NumberF.Password.is_valid_password?("Correct-Horse-7")
      true

      iex> NumberF.Password.is_valid_password?("correct-horse-7")
      false

      iex> NumberF.Password.is_valid_password?(nil)
      false
  """
  def is_valid_password?(password, policy \\ []) do
    policy = normalise_policy!(policy)
    is_binary(password) and violations(password, policy) == []
  end

  # --- checking -------------------------------------------------------------

  defp violations(password, policy) do
    length = String.length(password)
    counts = password |> String.graphemes() |> Enum.frequencies_by(&classify/1)

    [
      too_short: length < policy.min_length,
      too_long: policy.max_length != nil and length > policy.max_length,
      too_few_uppercase: Map.get(counts, :uppercase, 0) < policy.uppercase,
      too_few_lowercase: Map.get(counts, :lowercase, 0) < policy.lowercase,
      too_few_digits: Map.get(counts, :digits, 0) < policy.digits,
      too_few_special: Map.get(counts, :special, 0) < policy.special
    ]
    |> Enum.filter(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
  end

  # Classified per grapheme by its leading code point, so a decomposed "é" (an "e"
  # followed by a combining accent) counts as one lowercase letter rather than a
  # letter plus a special character.
  defp classify(grapheme) do
    cond do
      grapheme =~ ~r/^\p{Lu}/u -> :uppercase
      grapheme =~ ~r/^\p{Ll}/u -> :lowercase
      grapheme =~ ~r/^\p{Nd}/u -> :digits
      grapheme =~ ~r/^\p{L}/u -> :other_letter
      true -> :special
    end
  end

  # --- generation -----------------------------------------------------------

  defp generated_length(policy) do
    max(policy.min_length, Enum.sum(Enum.map(@classes, &policy[&1])))
  end

  defp alphabets(policy) do
    exclude = if policy.exclude_ambiguous, do: @ambiguous, else: []

    %{
      uppercase: graphemes_without(@uppercase, exclude),
      lowercase: graphemes_without(@lowercase, exclude),
      digits: graphemes_without(@digits, exclude),
      # Specials cannot hold letters or digits (the policy check rejects them), so
      # there is nothing ambiguous to take out.
      special: graphemes_without(policy.special_chars, [])
    }
  end

  defp graphemes_without(string, exclude) do
    string |> String.graphemes() |> Enum.uniq() |> Kernel.--(exclude) |> List.to_tuple()
  end

  defp merge_alphabets(alphabets) do
    alphabets |> Enum.flat_map(&Tuple.to_list/1) |> List.to_tuple()
  end

  defp pick(alphabet, state) do
    {index, state} = :rand.uniform_s(tuple_size(alphabet), state)
    {elem(alphabet, index - 1), state}
  end

  # Fisher-Yates, so every arrangement is equally likely. Without it the required
  # characters would always lead, in class order, and an attacker would know the
  # first character of every default password is an uppercase letter.
  defp shuffle(chars, state) do
    last = length(chars) - 1
    indexed = chars |> Enum.with_index() |> Map.new(fn {char, index} -> {index, char} end)

    {shuffled, state} =
      Enum.reduce(last..1//-1, {indexed, state}, fn i, {acc, state} ->
        {j, state} = :rand.uniform_s(i + 1, state)
        j = j - 1
        {%{acc | i => acc[j], j => acc[i]}, state}
      end)

    {Enum.map(0..last, &shuffled[&1]), state}
  end

  # --- policy ---------------------------------------------------------------

  defp normalise_policy!(policy) do
    unless Keyword.keyword?(policy) do
      raise ArgumentError,
            "expected policy to be a keyword list, got: #{inspect(policy)}"
    end

    case Keyword.keys(policy) -- @policy_keys do
      [] ->
        :ok

      [key | _] ->
        raise ArgumentError,
              "unknown password policy key #{inspect(key)}, " <>
                "expected one of: #{inspect(Enum.sort(@policy_keys))}"
    end

    policy = Map.merge(@defaults, Map.new(policy))

    Enum.each(@classes, &check_count!(policy, &1))
    check_lengths!(policy)
    check_classes!(policy)
    check_special_chars!(policy)

    unless is_boolean(policy.exclude_ambiguous) do
      raise ArgumentError,
            "password policy :exclude_ambiguous must be a boolean, " <>
              "got: #{inspect(policy.exclude_ambiguous)}"
    end

    policy
  end

  defp check_count!(policy, key) do
    case policy[key] do
      count when is_integer(count) and count >= 0 ->
        :ok

      other ->
        raise ArgumentError,
              "password policy #{inspect(key)} must be a non-negative integer, got: #{inspect(other)}"
    end
  end

  defp check_lengths!(%{min_length: min, max_length: max} = policy) do
    unless is_integer(min) and min >= 1 do
      raise ArgumentError,
            "password policy :min_length must be a positive integer, got: #{inspect(min)}"
    end

    cond do
      is_nil(max) ->
        :ok

      not is_integer(max) ->
        raise ArgumentError,
              "password policy :max_length must be an integer or nil, got: #{inspect(max)}"

      max < min ->
        raise ArgumentError,
              "password policy :max_length (#{max}) is less than :min_length (#{min})"

      true ->
        required = Enum.sum(Enum.map(@classes, &policy[&1]))

        if required > max do
          raise ArgumentError,
                "password policy :max_length (#{max}) is less than the class minimums " <>
                  "(:uppercase + :lowercase + :digits + :special = #{required})"
        end
    end
  end

  # With every class at 0 the generator has no alphabet to draw from.
  defp check_classes!(policy) do
    if Enum.all?(@classes, &(policy[&1] == 0)) do
      raise ArgumentError,
            "password policy must require at least one of " <>
              ":uppercase, :lowercase, :digits or :special"
    end
  end

  defp check_special_chars!(%{special_chars: chars, special: special}) do
    cond do
      not is_binary(chars) ->
        raise ArgumentError,
              "password policy :special_chars must be a string, got: #{inspect(chars)}"

      special > 0 and chars == "" ->
        raise ArgumentError,
              "password policy :special_chars is empty but :special requires #{special}"

      # The checker counts letters and digits as their own class, so a generated
      # "special" drawn from them would fail the generator's own policy.
      chars =~ ~r/[\p{L}\p{Nd}]/u ->
        raise ArgumentError,
              "password policy :special_chars must not contain letters or digits, " <>
                "got: #{inspect(chars)}"

      true ->
        :ok
    end
  end
end

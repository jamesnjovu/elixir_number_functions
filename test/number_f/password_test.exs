defmodule NumberF.PasswordTest do
  use ExUnit.Case, async: true

  alias NumberF.Password

  # Random output, so every property is checked over many samples rather than one.
  @samples 200

  defp samples(policy \\ []), do: for(_ <- 1..@samples, do: Password.generate_password(policy))

  defp count(password, regex), do: regex |> Regex.scan(password) |> length()

  describe "generate_password/1 with the default policy" do
    test "satisfies its own policy every time" do
      for password <- samples() do
        assert String.length(password) == 12
        assert Password.validate_password(password) == :ok
      end
    end

    test "draws only from the default alphabets" do
      for password <- samples() do
        assert password =~ ~r/^[A-Za-z0-9!@#$%^&*\-_=+?]+$/
      end
    end

    test "does not always put the required classes first" do
      # Before shuffling, the first character would always be the uppercase one.
      first_chars = samples() |> Enum.map(&String.first/1)
      refute Enum.all?(first_chars, &(&1 =~ ~r/^[A-Z]$/))
    end

    test "is not the same password twice" do
      assert samples() |> Enum.uniq() |> length() == @samples
    end
  end

  describe "generate_password/1 honours the policy" do
    test "custom class minimums" do
      policy = [min_length: 10, uppercase: 3, lowercase: 2, digits: 4, special: 1]

      for password <- samples(policy) do
        assert String.length(password) == 10
        assert count(password, ~r/[A-Z]/) >= 3
        assert count(password, ~r/[a-z]/) >= 2
        assert count(password, ~r/[0-9]/) >= 4
        assert count(password, ~r/[^A-Za-z0-9]/) >= 1
      end
    end

    test "grows past :min_length when the class minimums need more room" do
      password = Password.generate_password(min_length: 4, uppercase: 3, digits: 3)
      assert String.length(password) == 3 + 1 + 3 + 1
    end

    test "a longer :min_length" do
      assert String.length(Password.generate_password(min_length: 64)) == 64
    end

    test "a class set to 0 never appears" do
      for password <- samples(special: 0), do: assert(password =~ ~r/^[A-Za-z0-9]+$/)
      for password <- samples(uppercase: 0), do: refute(password =~ ~r/[A-Z]/)
      for password <- samples(lowercase: 0), do: refute(password =~ ~r/[a-z]/)
      for password <- samples(digits: 0), do: refute(password =~ ~r/[0-9]/)
    end

    test "a single required class" do
      policy = [min_length: 8, uppercase: 0, lowercase: 0, special: 0, digits: 1]
      for password <- samples(policy), do: assert(password =~ ~r/^[0-9]{8}$/)
    end

    test "draws specials only from :special_chars" do
      policy = [min_length: 20, special: 5, special_chars: "#~"]

      for password <- samples(policy) do
        assert count(password, ~r/[#~]/) >= 5
        assert password =~ ~r/^[A-Za-z0-9#~]+$/
      end
    end

    test "a non-ASCII special character counts as one grapheme" do
      policy = [
        min_length: 6,
        special: 6,
        uppercase: 0,
        lowercase: 0,
        digits: 0,
        special_chars: "€"
      ]

      assert Password.generate_password(policy) == "€€€€€€"
    end

    test "a policy with :max_length equal to the length is satisfiable" do
      policy = [min_length: 8, max_length: 8]

      for password <- samples(policy),
          do: assert(Password.validate_password(password, policy) == :ok)
    end
  end

  describe "generate_password/1 and :exclude_ambiguous" do
    test "leaves out I, l, 1, O and 0 by default" do
      passwords = Enum.join(samples(min_length: 200))
      refute passwords =~ ~r/[Il1O0]/
    end

    test "includes them when switched off" do
      passwords = Enum.join(samples(min_length: 200, exclude_ambiguous: false))

      for char <- ~w(I l 1 O 0) do
        assert String.contains?(passwords, char), "#{char} never appeared"
      end
    end
  end

  describe "generate_password/1 randomness" do
    test "leaves the caller's :rand state exactly as it was" do
      :rand.seed(:exsss, {1, 2, 3})
      before = :rand.export_seed()

      Password.generate_password(min_length: 50)

      assert :rand.export_seed() == before
    end

    test "does not seed :rand in a process that never seeded it" do
      task =
        Task.async(fn ->
          Password.generate_password()
          :rand.export_seed()
        end)

      assert Task.await(task) == :undefined
    end
  end

  describe "the generator and the checker agree" do
    @policies [
      [],
      [min_length: 8],
      [min_length: 32, uppercase: 4, lowercase: 4, digits: 4, special: 4],
      [min_length: 6, max_length: 10, special: 0],
      [uppercase: 0, digits: 0, special: 0],
      [special_chars: "~", special: 3, exclude_ambiguous: false],
      [min_length: 1, uppercase: 0, lowercase: 0, digits: 0]
    ]

    for policy <- @policies do
      test "for #{inspect(policy)}" do
        policy = unquote(policy)

        for password <- samples(policy) do
          assert Password.validate_password(password, policy) == :ok
          assert Password.is_valid_password?(password, policy)
        end
      end
    end
  end

  describe "validate_password/2 reasons" do
    test "each reason on its own" do
      assert Password.validate_password("Abcdefghi1!") == {:error, [:too_short]}
      assert Password.validate_password("Abcdefghij1!", max_length: 12) == :ok
      assert Password.validate_password("Abcdefghijk1!", max_length: 12) == {:error, [:too_long]}
      assert Password.validate_password("abcdefghij1!") == {:error, [:too_few_uppercase]}
      assert Password.validate_password("ABCDEFGHIJ1!") == {:error, [:too_few_lowercase]}
      assert Password.validate_password("Abcdefghijk!") == {:error, [:too_few_digits]}
      assert Password.validate_password("Abcdefghijk1") == {:error, [:too_few_special]}
    end

    test "several reasons come back in the fixed order" do
      assert Password.validate_password("") ==
               {:error,
                [
                  :too_short,
                  :too_few_uppercase,
                  :too_few_lowercase,
                  :too_few_digits,
                  :too_few_special
                ]}

      assert Password.validate_password("!!!!!!!!!!!!!", max_length: 12) ==
               {:error, [:too_long, :too_few_uppercase, :too_few_lowercase, :too_few_digits]}
    end

    test "counts against the class minimums, not just presence" do
      policy = [uppercase: 2, digits: 3]

      assert Password.validate_password("Abcdefghi12!", policy) ==
               {:error, [:too_few_uppercase, :too_few_digits]}

      assert Password.validate_password("ABcdefgh123!", policy) == :ok
    end

    test "a class at 0 is accepted when present" do
      assert Password.validate_password("Abcdefghij1!", special: 0) == :ok
      assert Password.validate_password("Abcdefghij12", special: 0) == :ok
    end

    test "any non-letter, non-digit counts as special, even outside :special_chars" do
      assert Password.validate_password("Abcdefghij1~", special_chars: "!") == :ok
      assert Password.validate_password("Abcdefghij1 ") == :ok
    end

    test "letters and digits are counted by Unicode class" do
      assert Password.validate_password("Ñandú-ÉCOLE-٣") == :ok
      # A Han character is a letter but neither upper nor lower case, nor special.
      assert Password.validate_password("Abcdefghij1漢") == {:error, [:too_few_special]}
    end

    test "length is counted in graphemes, and a combining accent is not a special" do
      decomposed = String.normalize("é", :nfd)
      assert byte_size(decomposed) == 3

      password = "Abcdefghij1" <> decomposed
      assert String.length(password) == 12
      assert Password.validate_password(password) == {:error, [:too_few_special]}
    end

    test ":exclude_ambiguous does not affect checking" do
      assert Password.validate_password("Il1O0abcdef!", exclude_ambiguous: true) == :ok
    end
  end

  describe "non-string passwords" do
    test "is_valid_password?/2 returns false" do
      for value <- [nil, 12_345_678_901_234, :password, ~c"Abcdefghij1!", %{}] do
        refute Password.is_valid_password?(value)
      end
    end

    test "validate_password/2 raises naming the password" do
      for value <- [nil, 12_345_678_901_234, :password] do
        error = assert_raise ArgumentError, fn -> Password.validate_password(value) end
        assert error.message =~ "password"
        assert error.message =~ inspect(value)
      end
    end
  end

  describe "invalid policies raise ArgumentError naming the key" do
    @invalid [
      {[colour: 1], ":colour"},
      {16, "policy"},
      {%{min_length: 8}, "policy"},
      {[:min_length], "policy"},
      {[min_length: 0], ":min_length"},
      {[min_length: -1], ":min_length"},
      {[min_length: 8.0], ":min_length"},
      {[min_length: nil], ":min_length"},
      {[max_length: "16"], ":max_length"},
      {[max_length: 8], ":max_length"},
      {[min_length: 2, max_length: 3], ":max_length"},
      {[uppercase: -1], ":uppercase"},
      {[lowercase: 1.5], ":lowercase"},
      {[digits: "1"], ":digits"},
      {[special: nil], ":special"},
      {[uppercase: 0, lowercase: 0, digits: 0, special: 0], ":uppercase"},
      {[special_chars: ""], ":special_chars"},
      {[special_chars: :symbols], ":special_chars"},
      {[special_chars: "ab!"], ":special_chars"},
      {[special_chars: "!1"], ":special_chars"},
      {[exclude_ambiguous: "yes"], ":exclude_ambiguous"},
      {[exclude_ambiguous: nil], ":exclude_ambiguous"}
    ]

    for {policy, key} <- @invalid do
      test "#{inspect(policy)}" do
        policy = unquote(Macro.escape(policy))
        key = unquote(key)

        for fun <- [
              fn -> Password.generate_password(policy) end,
              fn -> Password.validate_password("Abcdefghij1!", policy) end,
              fn -> Password.is_valid_password?("Abcdefghij1!", policy) end,
              fn -> Password.is_valid_password?(nil, policy) end
            ] do
          error = assert_raise ArgumentError, fun
          assert error.message =~ key
        end
      end
    end

    test "an empty :special_chars is fine when no specials are required" do
      password = Password.generate_password(special: 0, special_chars: "")
      assert password =~ ~r/^[A-Za-z0-9]{12}$/
    end
  end

  describe "the facade" do
    test "delegates every function with the same defaults" do
      assert String.length(NumberF.generate_password()) == 12
      assert String.length(NumberF.generate_password(min_length: 20)) == 20
      assert NumberF.validate_password("short") == Password.validate_password("short")
      assert NumberF.is_valid_password?("Correct-Horse-7")
      refute NumberF.is_valid_password?("Correct-Horse-7", min_length: 16)
    end
  end
end

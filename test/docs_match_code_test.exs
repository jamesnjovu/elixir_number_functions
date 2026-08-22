defmodule NumberF.DocsMatchCodeTest do
  @moduledoc """
  Executes the cheatsheet and checks the facade's documentation coverage.

  This file exists because the documentation is a product here, not a courtesy:
  `llms.txt`, `llms-full.txt` and the cheatsheet are what AI assistants read when
  someone asks how to use this library, and a confidently wrong example is worse
  than no example. The v0.2.0 audit found five documented outputs that the library
  did not actually produce, a "25+ locales" claim that was really 22, and two
  functions whose implementation hardcoded their own doctest input so the doctest
  passed while testing nothing.

  Module and function docs are already covered by `doctest`. What is not covered
  anywhere else is the hand-written cheatsheet, which is the densest and most
  retrievable page in the docs.
  """
  use ExUnit.Case, async: true

  @cheatsheet Path.expand(Path.join([__DIR__, "..", "guides", "cheatsheet.cheatmd"]))

  # The cheatsheet's convention, which this test enforces: every `# =>` comment is
  # either a real Elixir term, or is elided with `...`, or carries one of these
  # markers in a two-space-separated aside. Prose in the value position is not
  # allowed, because there is then no way to tell a description from a claim.
  @unassertable ~w(random yours will differ today)

  describe "the cheatsheet" do
    test "exists and is shipped in the Hex package" do
      assert File.exists?(@cheatsheet)

      files = Mix.Project.config()[:package][:files]

      assert "guides" in files,
             "guides/ must be in mix.exs :files or the cheatsheet never reaches consumers"
    end

    test "every asserted example evaluates to the value it claims" do
      failures =
        @cheatsheet
        |> File.read!()
        |> extract_examples()
        |> Enum.flat_map(&check_example/1)

      assert failures == [],
             "the cheatsheet claims outputs the library does not produce:\n\n" <>
               Enum.join(failures, "\n\n")
    end
  end

  describe "the facade's documentation" do
    test "every public function carries a @doc group, so the docs sidebar stays grouped" do
      {:docs_v1, _, _, _, _, _, docs} = Code.fetch_docs(NumberF)

      ungrouped =
        for {{:function, name, arity}, _line, _sig, doc, metadata} <- docs,
            doc != :hidden,
            is_nil(metadata[:group]),
            do: "#{name}/#{arity}"

      assert ungrouped == [],
             "these facade functions have no `@doc group:` and will land ungrouped in " <>
               "the generated docs: #{inspect(Enum.sort(ungrouped))}"
    end

    test "every public function is documented" do
      {:docs_v1, _, _, _, _, _, docs} = Code.fetch_docs(NumberF)

      undocumented =
        for {{:function, name, arity}, _line, _sig, doc, _meta} <- docs,
            doc == :none,
            do: "#{name}/#{arity}"

      assert undocumented == [],
             "public but undocumented: #{inspect(Enum.sort(undocumented))}"
    end
  end

  # --- extraction -----------------------------------------------------------

  # Matches a `NumberF.…` expression followed by a `# => …` comment, either on the
  # next line or trailing the same line. Multi-line expected values continue on
  # subsequent comment lines.
  defp extract_examples(source) do
    lines = String.split(source, "\n")

    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, index} -> example_at(lines, line, index) end)
  end

  defp example_at(lines, line, index) do
    trailing = Regex.run(~r/^(NumberF\.[A-Za-z0-9_?!]+\(.*\))\s+# => (.+)$/, line)
    standalone = Regex.run(~r/^(NumberF\.[A-Za-z0-9_?!]+\(.*\))\s*$/, line)
    next = lines |> Enum.at(index + 1, "") |> String.trim()

    cond do
      trailing ->
        [_, expr, expected] = trailing
        [{expr, expected}]

      standalone && String.starts_with?(next, "# => ") ->
        [_, expr] = standalone
        [{expr, continuation(lines, index + 1)}]

      true ->
        []
    end
  end

  defp continuation(lines, start) do
    first = lines |> Enum.at(start) |> String.trim() |> String.replace_prefix("# => ", "")

    rest =
      lines
      |> Enum.drop(start + 1)
      |> Enum.take_while(fn l ->
        trimmed = String.trim(l)
        String.starts_with?(trimmed, "#") and not String.starts_with?(trimmed, "# =>")
      end)
      |> Enum.map_join(" ", &(&1 |> String.trim() |> String.trim_leading("#") |> String.trim()))

    String.trim(first <> " " <> rest)
  end

  # --- checking -------------------------------------------------------------

  defp check_example({expr, raw_expected}) do
    expected = strip_aside(raw_expected)

    cond do
      expected == "" or String.contains?(expected, "...") -> []
      Enum.any?(@unassertable, &String.contains?(raw_expected, &1)) -> []
      true -> compare(expr, expected)
    end
  end

  # An aside after two or more spaces is prose, not part of the value:
  #     # => "¥1,235"    (JPY has 0 decimal places)
  defp strip_aside(text), do: text |> String.replace(~r/\s{2,}\(.*$/, "") |> String.trim()

  defp compare(expr, expected) do
    actual = expr |> Code.eval_string([], __ENV__) |> elem(0)
    want = expected |> Code.eval_string([], __ENV__) |> elem(0)

    if actual == want do
      []
    else
      ["  #{expr}\n    claims:  #{inspect(want)}\n    returns: #{inspect(actual)}"]
    end
  rescue
    error -> ["  #{expr}\n    raised: #{Exception.message(error)}"]
  end
end

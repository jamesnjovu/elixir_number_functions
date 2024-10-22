defmodule NumberF.MixProject do
  use Mix.Project

  def project do
    [
      app: :number_f,
      version: "0.1.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "NumberF",
      source_url: "https://github.com/jamesnjovu/elixir_number_functions",
      description: "Perform Simple Number Function in elixir",
      docs: docs(),
      package: package(),
      xref: [exclude: [:httpc, :public_key]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NumberF.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:number, "~> 1.0.1"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end


  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mveytsman/heroicons_elixir"}
    ]
  end

  defp docs do
    []
  end
end

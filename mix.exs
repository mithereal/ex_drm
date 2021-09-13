defmodule Drm.MixProject do
  use Mix.Project

  @source_url "https://github.com/mithereal/ex_drm.git"
  @version "0.2.1"

  def project do
    [
      app: :drm,
      version: @version,
      build_path: "./_build",
      config_path: "./config/config.exs",
      deps_path: "./deps",
      lockfile: "./mix.lock",
      elixir: "~> 1.9",
      name: "drm",
      source_url: @source_url,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      aliases: aliases(),
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Drm.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:burnex, "~> 1.0"},
      {:jason, "~> 1.1"},
      {:cloak, "1.1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:inch_ex, ">= 0.0.0", only: [:test, :dev]}
    ]
  end

  defp aliases do
    [
      test: ["test"]
    ]
  end

  defp description() do
    "Add drm to your elixir app(s) by using this simple license server."
  end

  defp package() do
    [
      name: "drm",
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Jason Clark"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mithereal/ex_drm"}
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "Drm",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/drm",
      source_url: @source_url,
      extras: ["README.md", "LICENSE"]
    ]
  end
end

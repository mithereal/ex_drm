defmodule Drm.MixProject do
  use Mix.Project

  def project do
    [
      app: :drm,
      version: "0.1.2",
      build_path: "./_build",
      config_path: "./config/config.exs",
      deps_path: "./deps",
      lockfile: "./mix.lock",
      elixir: "~> 1.8",
      name: "drm",
      source_url: "https://github.com/mithereal/elixir_drm",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.1"},
      {:argon2_elixir, "~> 2.0"},
      {:burnex, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:ex_doc, "~> 0.14", only: :dev},
      {:inch_ex, ">= 0.0.0", only: :docs}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end


  defp description() do
    "Add drm to your elixir app by using this simple license server."
  end

  defp package() do
    [
      name: "drm",
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Jason Clark"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mithereal/elixir_drm"}
    ]
  end
end

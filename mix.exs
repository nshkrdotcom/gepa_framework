Code.require_file("build_support/workspace_contract.exs", __DIR__)

unless Code.ensure_loaded?(DependencySources) do
  Code.require_file("build_support/dependency_sources.exs", __DIR__)
end

defmodule GEPAFramework.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nshkrdotcom/gepa_framework"

  def project do
    [
      app: :gepa_framework,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: docs(),
      dialyzer: [plt_add_deps: :apps_direct, plt_add_apps: [:outer_brain_context_abi]],
      name: "GEPA Framework",
      description: "Reusable GEPA optimizer framework",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      package_paths: GEPAFramework.Build.WorkspaceContract.package_paths()
    ]
  end

  def application do
    [extra_applications: [:crypto, :logger, :outer_brain_context_abi]]
  end

  def cli do
    [
      preferred_envs: [
        ci: :test,
        credo: :test,
        dialyzer: :test,
        docs: :dev
      ]
    ]
  end

  defp deps do
    DependencySources.deps(__DIR__) ++
      [
        {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
        {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
        {:ex_doc, "~> 0.40.1", only: [:dev, :test], runtime: false}
      ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib assets build_support mix.exs README.md LICENSE AGENTS.md .formatter.exs)
    ]
  end

  defp aliases do
    [
      ci: [
        "deps.get",
        "format --check-formatted",
        "compile --warnings-as-errors",
        "test",
        "credo --strict",
        "dialyzer --format short",
        "docs"
      ]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "main",
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end
end

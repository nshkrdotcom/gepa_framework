Code.require_file("build_support/workspace_contract.exs", __DIR__)

# `build_support/` is not shipped in the published package, so its absence is
# how this file knows it is running inside a consumer's deps/ rather than in a
# source checkout. Guard on the file, not on a directory shape: a shape test
# breaks when the repo is vendored at a different depth or used as a git dep.
workspace_helper = Path.expand("build_support/dependency_sources.exs", __DIR__)

if File.regular?(workspace_helper) and not Code.ensure_loaded?(DependencySources) do
  Code.require_file(workspace_helper)
end

defmodule GEPAFramework.MixProject do
  use Mix.Project

  @workspace_checkout? File.regular?(Path.expand("build_support/dependency_sources.exs", __DIR__))

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
    workspace_deps() ++
      [
        {:credo, "~> 1.7.19", only: [:dev, :test], runtime: false},
        {:dialyxir, "~> 1.4.7", only: [:dev, :test], runtime: false},
        {:ex_doc, "~> 0.40.3", only: [:dev, :test], runtime: false}
      ]
  end


  # In a source checkout the registry decides the source (path first). In a
  # published package there is no registry, and the requirement stated here is
  # the whole answer.
  defp workspace_dep(app, hex_requirement, opts \\ []) do
    if @workspace_checkout? do
      apply(DependencySources, :dep, [app, __DIR__, opts])
    else
      if opts == [], do: {app, hex_requirement}, else: {app, hex_requirement, opts}
    end
  end

  defp workspace_deps do
    if @workspace_checkout? do
      apply(DependencySources, :deps, [__DIR__])
    else
      [{:mezzanine_ai_execution_engine, "~> 0.1.0"}, {:outer_brain_context_abi, "~> 0.1.0"}]
    end
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files:
        ~w(lib assets guides mix.exs README.md LICENSE AGENTS.md .formatter.exs)
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
      extras: [
        "README.md",
        {"guides/index.md", filename: "guides_index"},
        "guides/generalized_stack.md",
        "guides/eval_and_promotion.md",
        "guides/stacklab_acceptance.md",
        "guides/qc_and_operations.md"
      ],
      groups_for_extras: [
        Overview: ["README.md", "guides/index.md"],
        Architecture: ["guides/generalized_stack.md", "guides/eval_and_promotion.md"],
        Operations: ["guides/stacklab_acceptance.md", "guides/qc_and_operations.md"]
      ],
      source_ref: "main",
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end
end

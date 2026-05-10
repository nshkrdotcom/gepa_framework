Code.require_file("workspace_contract.exs", __DIR__)

defmodule GEPAFramework.Build.WeldContract do
  @moduledoc false

  def manifest do
    [
      workspace: [
        root: "..",
        project_globs: GEPAFramework.Build.WorkspaceContract.active_project_globs()
      ],
      classify: [
        tooling: ["."]
      ],
      publication: [
        internal_only: ["."]
      ],
      artifacts: [
        gepa_framework: artifact()
      ]
    ]
  end

  def artifact do
    [
      roots: ["."],
      package: [
        name: "gepa_framework",
        otp_app: :gepa_framework,
        version: "0.1.0",
        description: "Reusable GEPA optimizer framework"
      ],
      output: [
        docs: ["README.md"],
        assets: ["assets/gepa_framework.svg"]
      ],
      verify: [
        artifact_tests: ["test"],
        hex_build: false,
        hex_publish: false
      ]
    ]
  end
end

GEPAFramework.Build.WeldContract.manifest()

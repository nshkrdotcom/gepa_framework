%{
  deps: %{
    mezzanine_ai_execution_engine: %{
      path: "../mezzanine/core/ai_execution_engine",
      github: %{
        repo: "nshkrdotcom/mezzanine",
        branch: "main",
        subdir: "core/ai_execution_engine"
      },
      hex: "~> 0.1.0",
      default_order: [:path, :github, :hex],
      publish_order: [:hex]
    },
    outer_brain_context_abi: %{
      path: "../outer_brain/core/context_abi",
      github: %{
        repo: "nshkrdotcom/outer_brain",
        branch: "main",
        subdir: "core/context_abi"
      },
      hex: "~> 0.1.0",
      default_order: [:path, :github, :hex],
      publish_order: [:hex]
    }
  }
}

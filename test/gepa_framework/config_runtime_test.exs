defmodule GEPAFramework.ConfigRuntimeTest do
  use ExUnit.Case, async: true

  test "compiles typed config into deterministic runtime spec and runs without live providers" do
    config_input = [
      runtime_ref: "run:gepa:phase6",
      task: %{
        task_ref: "task:answer-quality",
        dataset_ref: "dataset:phase6:train"
      },
      components: [
        %{
          component_ref: "component:instruction:v1",
          kind: :instruction,
          content_ref: "artifact:prompt:instruction:v1"
        }
      ],
      adapters: [
        %{
          adapter_ref: "adapter:mock-llm",
          type: :llm,
          mode: :deterministic_mock
        }
      ],
      data_loader: %{
        loader_ref: "loader:inline",
        example_refs: ["example:phase6:1", "example:phase6:2"]
      },
      evaluator: %{
        evaluator_ref: "eval:exact",
        objective_refs: ["objective:exact"]
      },
      proposer: %{
        proposer_ref: "proposer:deterministic",
        strategy: :deterministic_reflection
      },
      merge: %{
        merge_ref: "merge:disabled",
        strategy: :disabled
      },
      tracing: %{
        trace_refs: ["trace:phase6:config-runtime"]
      },
      persistence: %{
        profile: :memory_ephemeral
      }
    ]

    assert {:ok, %GEPAFramework.Config{} = config} =
             GEPAFramework.Config.compile(config_input)

    assert config.runtime_ref == "run:gepa:phase6"
    assert [%GEPAFramework.Component{}] = config.components
    assert config.persistence.profile == :memory_ephemeral
    refute config.persistence.restart_safe?

    assert {:ok, %GEPAFramework.GEPA.Result{} = result} =
             GEPAFramework.Runtime.run(config, examples: ["example:phase6:1", "example:phase6:2"])

    assert result.run_ref == "run:gepa:phase6"
    assert result.provider_dependency? == false
    assert result.checkpoint.profile == :memory_ephemeral
    refute result.checkpoint.restart_safe?
    assert result.best_candidate_ref in result.candidate_refs
    assert result.trace_refs == ["trace:phase6:config-runtime"]
  end
end

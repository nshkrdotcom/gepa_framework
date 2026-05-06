defmodule GEPAFramework.CandidateTest do
  use ExUnit.Case, async: true

  alias GEPAFramework.GEPA.Candidate

  test "wraps compact component maps with typed refs and memory checkpoint posture" do
    assert {:ok, %Candidate{} = candidate} =
             Candidate.wrap(%{
               candidate_ref: "candidate:instruction:v2",
               components: %{
                 "instruction" => %{
                   component_ref: "component:instruction:v2",
                   content_ref: "artifact:prompt:instruction:v2"
                 }
               },
               lineage_refs: ["lineage:phase6:1"],
               diff_refs: ["diff:instruction:v1:v2"],
               parent_refs: ["candidate:instruction:v1"],
               merge_refs: ["merge:disabled"],
               objective_refs: ["objective:exact"],
               rejection_reasons: [],
               trace_refs: ["trace:candidate:v2"]
             })

    assert candidate.candidate_ref == "candidate:instruction:v2"
    assert candidate.lineage_refs == ["lineage:phase6:1"]
    assert candidate.diff_refs == ["diff:instruction:v1:v2"]
    assert candidate.parent_refs == ["candidate:instruction:v1"]
    assert candidate.merge_refs == ["merge:disabled"]
    assert candidate.objective_refs == ["objective:exact"]
    assert candidate.rejection_reasons == []
    assert candidate.checkpoint.profile == :memory_ephemeral
    refute candidate.checkpoint.restart_safe?

    assert Candidate.to_projection(candidate) == %{
             candidate_ref: "candidate:instruction:v2",
             component_refs: ["component:instruction:v2"],
             lineage_refs: ["lineage:phase6:1"],
             diff_refs: ["diff:instruction:v1:v2"],
             parent_refs: ["candidate:instruction:v1"],
             merge_refs: ["merge:disabled"],
             objective_refs: ["objective:exact"],
             rejection_reasons: [],
             checkpoint: %{profile: :memory_ephemeral, restart_safe?: false},
             trace_refs: ["trace:candidate:v2"]
           }
  end

  test "rejects raw prompt, provider, model, memory, and secret payload fields" do
    forbidden_cases = [
      %{prompt: "raw prompt"},
      %{"provider_payload" => %{body: "raw"}},
      %{model_output: "raw output"},
      %{memory_body: "raw memory"},
      %{secret: "token"}
    ]

    for forbidden <- forbidden_cases do
      input =
        Map.merge(
          %{
            candidate_ref: "candidate:forbidden",
            components: %{
              "instruction" => %{
                component_ref: "component:instruction:v1",
                content_ref: "artifact:prompt:instruction:v1"
              }
            }
          },
          forbidden
        )

      assert {:error, {:forbidden_raw_field, _field}} = Candidate.wrap(input)
    end
  end
end

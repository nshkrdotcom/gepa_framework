defmodule GEPA.MezzanineOptimizerAdapterTest do
  use ExUnit.Case, async: true

  alias GEPA.MezzanineOptimizerAdapter
  alias OuterBrain.ContextABI.Failure

  test "implements Mezzanine optimizer adapter with governed candidate receipts" do
    assert MezzanineOptimizerAdapter.behaviour_contract() ==
             Mezzanine.AIExecution.OptimizerAdapter

    assert {:ok, [candidate]} =
             MezzanineOptimizerAdapter.propose(optimization_request(),
               examples: ["example://gepa/phase13/1"]
             )

    assert candidate.candidate_ref == "candidate:component:gepa:mezzanine:1"
    assert candidate.lineage_refs == ["lineage:run:gepa:phase13"]
    assert candidate.objective_score_ref =~ ~r/^objective-score:\/\/gepa\/[0-9a-f]{16}$/
    assert candidate.promotion_required? == true
    assert candidate.trace_ref == "trace://gepa/phase13"
    assert candidate.context_packet_ref == "context-packet://tenant-a/run-a"
    assert candidate.route_decision_ref == "route-decision://tenant-a/run-a"
    assert candidate.eval_refs == ["eval://tenant-a/gepa"]
    assert candidate.cost_refs == ["cost://tenant-a/gepa"]
    assert candidate.promotion_refs == ["promotion://tenant-a/gepa"]
    assert candidate.rollback_refs == ["rollback://tenant-a/gepa"]
    assert candidate.component_refs == ["component:gepa:mezzanine:1"]
  end

  test "rejects raw payloads with owner-local GEPA failures" do
    request = Map.put(optimization_request(), :provider_payload, %{body: "raw"})

    assert {:error, %Failure{} = failure} = MezzanineOptimizerAdapter.propose(request)
    assert failure.owner == :gepa
    assert failure.reason_code == "gepa.optimization.raw_payload_rejected.v1"
    assert "field://provider_payload" in failure.evidence_refs
  end

  test "rejects credential-like and raw-prefixed optimization fields recursively" do
    for {field, value} <- [
          {:raw_data, "raw"},
          {"api_key", "secret"},
          {:token, "secret"},
          {"authorization", "Bearer secret"},
          {:nested, %{"raw_memory_context" => "raw"}}
        ] do
      request = Map.put(optimization_request(), field, value)

      assert {:error, %Failure{} = failure} = MezzanineOptimizerAdapter.propose(request)
      assert failure.reason_code == "gepa.optimization.raw_payload_rejected.v1"
    end
  end

  test "requires candidate source lineage refs" do
    request = Map.put(optimization_request(), :candidate_source_refs, [])

    assert {:error, %Failure{} = failure} = MezzanineOptimizerAdapter.propose(request)
    assert failure.owner == :gepa
    assert failure.reason_code == "gepa.optimization.candidate_lineage_missing.v1"
    assert "field://candidate_source_refs" in failure.evidence_refs
  end

  defp optimization_request do
    %{
      tenant_ref: "tenant://tenant-a",
      run_ref: "run:gepa:phase13",
      objective_ref: "objective://tenant-a/quality",
      candidate_source_refs: ["prompt-artifact://tenant-a/instruction/v1"],
      promotion_policy_ref: "promotion-policy://tenant-a/default",
      trace_ref: "trace://gepa/phase13",
      context_packet_ref: "context-packet://tenant-a/run-a",
      route_decision_ref: "route-decision://tenant-a/run-a",
      eval_refs: ["eval://tenant-a/gepa"],
      cost_refs: ["cost://tenant-a/gepa"],
      promotion_ref: "promotion://tenant-a/gepa",
      rollback_ref: "rollback://tenant-a/gepa"
    }
  end
end

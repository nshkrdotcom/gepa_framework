defmodule GEPAFramework.Adapters.Confidence do
  @moduledoc """
  Descriptor for confidence-scoring framework adapters.
  """

  @spec descriptor(String.t(), [String.t()]) :: map()
  def descriptor(adapter_ref, objective_refs)
      when is_binary(adapter_ref) and is_list(objective_refs) do
    %{adapter_ref: adapter_ref, type: :confidence, objective_refs: objective_refs}
  end
end

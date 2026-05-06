defmodule GEPAFramework.Adapters.GenericRAG do
  @moduledoc """
  Descriptor for Generic RAG framework adapters.
  """

  @spec descriptor(String.t(), [String.t()]) :: map()
  def descriptor(adapter_ref, artifact_refs)
      when is_binary(adapter_ref) and is_list(artifact_refs) do
    %{adapter_ref: adapter_ref, type: :generic_rag, artifact_refs: artifact_refs}
  end
end

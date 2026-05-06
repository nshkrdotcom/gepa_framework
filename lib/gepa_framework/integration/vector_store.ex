defmodule GEPAFramework.Integration.VectorStore do
  @moduledoc """
  Direct standalone vector-store integration behaviour for local experiments.
  """

  @callback search(map()) :: {:ok, map()} | {:error, term()}

  @spec descriptor(String.t(), atom()) :: map()
  def descriptor(adapter_ref, mode) when is_binary(adapter_ref) and is_atom(mode) do
    %{adapter_ref: adapter_ref, type: :vector_store, mode: mode}
  end
end

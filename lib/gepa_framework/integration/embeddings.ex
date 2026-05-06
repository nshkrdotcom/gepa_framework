defmodule GEPAFramework.Integration.Embeddings do
  @moduledoc """
  Direct standalone embedding integration behaviour for local experiments.
  """

  @callback embed(map()) :: {:ok, map()} | {:error, term()}

  @spec descriptor(String.t(), atom()) :: map()
  def descriptor(adapter_ref, mode) when is_binary(adapter_ref) and is_atom(mode) do
    %{adapter_ref: adapter_ref, type: :embeddings, mode: mode}
  end
end

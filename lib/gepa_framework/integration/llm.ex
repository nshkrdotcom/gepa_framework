defmodule GEPAFramework.Integration.LLM do
  @moduledoc """
  Direct standalone LLM integration behaviour for local experiments.
  """

  @callback complete(map()) :: {:ok, map()} | {:error, term()}

  @spec descriptor(String.t(), atom()) :: map()
  def descriptor(adapter_ref, mode) when is_binary(adapter_ref) and is_atom(mode) do
    %{adapter_ref: adapter_ref, type: :llm, mode: mode}
  end
end

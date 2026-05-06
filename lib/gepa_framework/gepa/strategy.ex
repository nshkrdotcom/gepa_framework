defmodule GEPAFramework.GEPA.Strategy do
  @moduledoc """
  Strategy contract for candidate selection and evaluation policy.
  """

  alias GEPAFramework.GEPA.State

  @callback choose(State.t()) :: {:ok, term()} | {:error, term()}

  @spec descriptor(String.t(), atom()) :: map()
  def descriptor(strategy_ref, type) when is_binary(strategy_ref) and is_atom(type) do
    %{strategy_ref: strategy_ref, type: type}
  end
end

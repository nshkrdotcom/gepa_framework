defmodule GEPAFramework.Runtime do
  @moduledoc """
  Deterministic local runtime for framework-level GEPA proofs.
  """

  alias GEPAFramework.Config
  alias GEPAFramework.GEPA.Engine

  @spec run(Config.t() | map() | keyword(), keyword()) ::
          {:ok, GEPAFramework.GEPA.Result.t()} | {:error, term()}
  def run(input, opts \\ []) do
    with {:ok, config} <- Config.compile(input) do
      Engine.run(config, opts)
    end
  end
end

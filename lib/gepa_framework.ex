defmodule GEPAFramework do
  @moduledoc """
  Public facade for the reusable GEPA optimizer framework.
  """

  alias GEPAFramework.{Config, Runtime}

  defdelegate compile_config(input), to: Config, as: :compile
  defdelegate run(input, opts \\ []), to: Runtime
end

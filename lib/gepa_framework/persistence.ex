defmodule GEPAFramework.Persistence do
  @moduledoc """
  Checkpoint and store posture for standalone framework runs.
  """

  alias GEPAFramework.Value

  @type profile :: :memory_ephemeral | :durable_explicit

  @type t :: %__MODULE__{
          profile: profile(),
          checkpoint_ref: String.t(),
          store_ref: String.t() | nil,
          durable_profile_ref: String.t() | nil,
          restart_safe?: boolean()
        }

  defstruct profile: :memory_ephemeral,
            checkpoint_ref: "checkpoint:memory:gepa",
            store_ref: nil,
            durable_profile_ref: nil,
            restart_safe?: false

  @spec default() :: t()
  def default, do: %__MODULE__{}

  @spec from_map(map() | keyword() | t() | nil) :: {:ok, t()} | {:error, term()}
  def from_map(nil), do: {:ok, default()}
  def from_map(%__MODULE__{} = persistence), do: validate(persistence)

  def from_map(input) do
    profile = normalize_profile(Value.get(input, :profile, :memory_ephemeral))

    persistence = %__MODULE__{
      profile: profile,
      checkpoint_ref: Value.get(input, :checkpoint_ref, "checkpoint:memory:gepa"),
      store_ref: Value.get(input, :store_ref),
      durable_profile_ref: Value.get(input, :durable_profile_ref),
      restart_safe?: restart_safe?(profile, input)
    }

    validate(persistence)
  end

  @spec to_projection(t()) :: map()
  def to_projection(%__MODULE__{} = persistence) do
    %{
      profile: persistence.profile,
      restart_safe?: persistence.restart_safe?
    }
  end

  defp normalize_profile(:durable_explicit), do: :durable_explicit
  defp normalize_profile("durable_explicit"), do: :durable_explicit
  defp normalize_profile(_profile), do: :memory_ephemeral

  defp restart_safe?(:durable_explicit, input) do
    Value.get(input, :restart_safe?, false) == true and
      is_binary(Value.get(input, :durable_profile_ref))
  end

  defp restart_safe?(_profile, _input), do: false

  defp validate(%__MODULE__{profile: :memory_ephemeral, restart_safe?: false} = persistence),
    do: {:ok, persistence}

  defp validate(%__MODULE__{profile: :durable_explicit, restart_safe?: true} = persistence)
       when is_binary(persistence.durable_profile_ref),
       do: {:ok, persistence}

  defp validate(%__MODULE__{profile: :durable_explicit}),
    do: {:error, :durable_profile_requires_restart_safe_evidence}

  defp validate(%__MODULE__{}), do: {:error, :invalid_persistence_profile}
end

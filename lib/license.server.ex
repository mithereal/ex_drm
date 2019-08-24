defmodule Drm.Server do
  use GenServer

  @moduledoc false

  @derive {Jason.Encoder, only: [:hash, :meta, :policy, :connections, :status]}

  @registry_name :license_registry
  @name __MODULE__

  require Hub
  require Logger

  alias Drm, as: LICENSE
  alias Drm.Server, as: LICENSESERVER
  alias Drm.LicenseRegistry, as: LICENSEREGISTRY

  defstruct filename: "",
            hash: "",
            meta: %{},
            policy: %{},
            connections: 0,
            status: :ok

  def child_spec(license) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [license]},
      type: :worker
    }
  end

  def start_link(data \\ [%{filename: "", hash: "", meta: %{}, policy: %{}}]) do
    name = via_tuple(data.hash)
    GenServer.start_link(__MODULE__, data, name: name)
  end

  def init(license) do
    Logger.info("license: " <> license.hash)

    filename =
      case Map.has_key?(license, :filename) do
        true -> license.filename
        false -> ""
      end

    {:ok,
     %__MODULE__{
       filename: filename,
       hash: license.hash,
       meta: license.meta,
       policy: license.policy,
       connections: 0,
       status: :ok
     }}
  end

  def handle_info({:setup, license}, state) do
    Hub.subscribe(license.hash, _)

    {:noreply, license}
  end

  def handle_info(:join, state) do
    connections = state.connections + 1

    status =
      case state.policy.validation_type do
        "strict" ->
          case connections > state.max_fingerprints do
            true -> {:error, "license limit exceeded"}
            false -> :ok
          end

        "floating" ->
          {:error, "license limit exceeded"}

        "concurrent" ->
          {:error, "license limit exceeded"}
      end

    updated_state = %__MODULE__{
      state
      | connections: connections,
        status: status
    }

    {:noreply, updated_state}
  end

  def handle_call(:show, _from, state) do
    {:reply, state, state}
  end

  defp via_tuple(name) do
    {:via, Registry, {@registry_name, name}}
  end
end

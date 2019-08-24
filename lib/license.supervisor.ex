defmodule Drm.License.Supervisor do
  use DynamicSupervisor

  @moduledoc false

  require Logger

  alias Drm.Server, as: LICENSESERVER

  @name __MODULE__

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  @spec start_link() :: Supervisor.on_start()
  def start_link() do
    DynamicSupervisor.start_link(strategy: :one_for_one, name: @name)
  end

  @spec start_child(String.t()) :: DynamicSupervisor.on_start_child()
  def start_child(license) do
    child_spec = {LICENSESERVER, license}
    DynamicSupervisor.start_child(@name, child_spec)
  end

  def remove_child(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # Nice utility method to check which processes are under supervision
  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  # Nice utility method to check which processes are under supervision
  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end

  def get_emails do
    licenses = Drm.License.Supervisor.children()

    Enum.map(licenses, fn {_, pid, _, _} ->
      license = GenServer.call(pid, :show)
      license.meta.email
    end)
  end

  def get_users do
    licenses = Drm.License.Supervisor.children()

    Enum.map(licenses, fn {_, pid, _, _} ->
      license = GenServer.call(pid, :show)
      license.meta.name
    end)
  end

  def get_fingerprints do
    licenses = Drm.License.Supervisor.children()

    fingerprints =
      Enum.map(licenses, fn {_, pid, _, _} ->
        license = GenServer.call(pid, :show)
        license.policy.fingerprint
      end)

    Enum.uniq(fingerprints)
  end
end

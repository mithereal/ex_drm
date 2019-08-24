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
  end
end

defmodule Drm.License.Supervisor do

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
  
  def start_link() do

    DynamicSupervisor.start_link(strategy: :one_for_one, name: @name)
  end

  @spec start_child(String.t()) :: DynamicSupervisor.on_start_child()
  def start_child(license) do
    DynamicSupervisor.start_child(@name, {LICENSESERVER, license})
  end

  end
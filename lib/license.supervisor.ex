defmodule License.License.Supervisor do
    require Logger

    alias License.Server, as: LICENSESERVER
  
  @registry_name :license_registry
  @name __MODULE__

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
  
  def start_link() do
    children = [
      {LICENSESERVER, []}
    ]
    Supervisor.start_link(children, name:  @name, strategy: :one_for_one_)
  end


  end
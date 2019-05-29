defmodule Drm.Server do

  use GenServer

   @moduledoc false
   
@registry_name :license_registry
@name __MODULE__

require Drm.Hub

alias Drm, as: LICENSE
alias Drm.Hub, as: HUB
alias License.Key.Server, as: KEYSERVER
alias Drm.Server, as: LICENSESERVER
alias Drm.LicenseRegistry, as: LICENSEREGISTRY
alias Drm.Channel.Supervisor, as: LICENSECHANNELSUPERVISOR


defstruct hash: "",
          meta: %{}, 
          policy: %{},
          connections: 0,
          status: :ok

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker
    }
  end          

  def start_link([], %{hash: "", meta: %{}, policy: %{}}) do
    start_link([%{hash: "", meta: %{}, policy: %{}}])
  end

def start_link(data \\ [%{hash: "", meta: %{}, policy: %{}}]) do
  
    GenServer.start_link(__MODULE__, data, name: @name)
  end

  
  def init([license]) do

    case LICENSEREGISTRY.register(license.hash) do
      :ok ->
        LICENSECHANNELSUPERVISOR.start_child(license.hash)
        send(self(), {:setup, license}) 
        {:ok, %__MODULE__{hash: license.hash, meta: license.meta, policy: license.policy, connections: 0, status: :ok}}

      {:duplicate_key, _pid} ->
        :ignore
    end
    
  end

    
  def handle_info({:setup, license} , state) do
    HUB.subscribe(license.hash, _ )
    
  {:noreply, license}
  end


  def handle_info(:join , state) do

    connections = state.connections + 1

   status =  case state.policy.validation_type do
      "strict" -> case connections > state.max_fingerprints do
        true -> LICENSE.delete(license)
        {:error, "license limit exceeded"}  
        false -> :ok
        end
      "floating"-> {:error, "license limit exceeded"}  
      "concurrent" -> {:error, "license limit exceeded"}  
    end

     updated_state =  %__MODULE__{
       state
       | connections: connections,
         status: status
     }

  {:noreply, updated_state }
  end

  defp via_tuple(data) do
    {:via, Registry, {@registry_name, data}}
  end

  
  end
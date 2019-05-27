defmodule Drm.Server do

   @moduledoc false
   
@registry_name :license_registry
@name __MODULE__

alias Drm, as: LICENSE
alias Drm.Hub, as: HUB
alias License.Key.Server, as: KEYSERVER
alias Drm.Server, as: LICENSESERVER
alias Drm.LicenseRegistry, as: LICENSEREGISTRY
alias License.Channel.Supervisor, as: LICENSECHANNELSUPERVISOR


defstruct hash: "",
          meta: %{}, 
          policy: %{}
          connections: 0

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker
    }
  end          

def start_link(data \\ [%{hash: "", meta: %{}, policy: %{}}]) do
  
    GenServer.start_link(__MODULE__, data, name: @name)
  end

  
  def init([license]) do

    case LICENSEREGISTRY.register(license.hash) do
      :ok ->
        LICENSECHANNELSUPERVISOR.start_child(license.hash)
        send(self(), {:setup, license}) 
        {:ok, %__MODULE__{hash: license.hash, meta: license.meta, policy: license.policy, connections: 0}}

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

    case state.policy.validation_type do
      "strict" -> case connections > state.max_fingerprints do
        true -> LICENSE.delete(license)
        {:error, "license limit exceeded"}  
        false -> {:error, "license limit exceeded"}  
        end
      "floating"-> {:error, "license limit exceeded"}  
      "concurrent" -> {:error, "license limit exceeded"}  
    end

    updated_state = state | %__MODULE__{connections: connections}

  {:noreply, updated_state }
  end

  defp via_tuple(data) do
    {:via, Registry, {@registry_name, data}}
  end

  
  end
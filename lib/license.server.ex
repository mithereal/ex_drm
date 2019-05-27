defmodule Drm.Server do

   @moduledoc false
   
@registry_name :license_registry
@name __MODULE__

alias Drm.Server, as: LICENSESERVER

defstruct meta: %{}, 
          policy: %{}

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker
    }
  end          

def start_link(data \\ [%{meta: %{}, policy: %{}}]) do
  ## generate a hash for the license name
    GenServer.start_link(__MODULE__, data, name: @name)
  end

    
  
  def init([license]) do
     #  send(self(), {:setup, license}) 
    {:ok, %__MODULE__{meta: license.meta, policy: license.policy}}
  end
    
  def handle_info({:setup, license} , state) do
   ## create proceess for each licennse key, and setup a socket so the client can connect, this will allow for seeing how many concurent connections we have, and how ot deal with license violations
   # License.Channel.Supervisor.start(license)
   # License.Channel.Supervisor.join(self.pid())
  {:noreply, state}
  end

  defp via_tuple(data) do
    {:via, Registry, {@registry_name, data}}
  end

  
  end
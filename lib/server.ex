defmodule License.Server do
    use GenServer

defstruct licenses: []

@registry_name :license_registry

def start_link(init \\ []) do
  
    GenServer.start_link(__MODULE__, init, name: License.Server)
  
  end

  def setup() do
    GenServer.call(License.Server, :setup)
  end
    
  def exists?(license) do
    GenServer.call(License.Server, {:exists, license})
  end
  
  def remove{license} do
    GenServer.call(License.Server, {:remove, license})
  end
  
  def list() do
    GenServer.call(License.Server, :list)
  end
  
  def init([]) do
    {:ok, %__MODULE__{}}
  end
    
  def import(license) do
    GenServer.cast(License.Server, {:import, license})
  end

  def export(id) do
    GenServer.call(License.Server, {:export, id})
  end
  
  def handle_call({:export , id},_, state) do
    export = Enum.reject(state.licenses, fn x -> x.policy.fingerprint != id end)
  {:reply, export, state}
  end

  def handle_call(:list,_, state) do
  {:reply, state, state}
  end
  

  def handle_call(:setup,_, state) do
    Enum.each(state.licenses, fn(x)->
        License.License.Supervisor.start(x)
    end)
    
  {:reply, state, state}
  end
  
  def handle_call({:exists, license},_, state) do
    exists = Enum.member?(state.licenses, license)
  {:reply, exists, state}
  end
  
  def handle_call({:remove, license},_, state) do
    licenses = Enum.reject(state.licenses, fn l -> l = license end)
  {:reply, :ok , %__MODULE__{
    state
    | licenses: licenses
  }}
  end
  
  def handle_cast({:import, license}, state) do
    licenses = state.licenses ++ [license]
    {:noreply,
    %__MODULE__{
      state
      | licenses: licenses
    }}
  end
  
  end
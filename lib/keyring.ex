defmodule Drm.Key.Ring do

defstruct licenses: []

def child_spec(_) do
  %{
    id: __MODULE__,
    start: {__MODULE__, :start_link, []},
    type: :worker
  }
end  

def start_link(init \\ []) do
  
  GenServer.start_link(__MODULE__, init, name: License.Key.Ring)

end
  
def exists?(license) do
  GenServer.call(License.Key.Ring, {:exists, license})
end

def remove{license} do
  GenServer.call(License.Key.Ring, {:remove, license})
end

def list() do
  GenServer.call(License.Key.Ring, :list)
end

def export(id) do
  GenServer.call(License.Key.Ring, {:export, id})
end

def init([]) do
  {:ok, %__MODULE__{}}
end
  
def import(license) do
  GenServer.cast(License.Key.Ring, {:import, license})
end

def handle_call({:export , id},_, state) do
  export = Enum.reject(state.licenses, fn x -> x.policy.fingerprint != id end)
{:reply, export, state}
end

def handle_call(:list,_, state) do
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
  
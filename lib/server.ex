defmodule License.Server do
    use GenServer

    defstruct licenses: []

    def start_link(init \\ []) do
  
      GenServer.start_link(__MODULE__, init, name: LicenseServer)
    end
  
def valid?(license) do
  
end


def show() do
  GenServer.call(LicenseServer, :show)
end

def init([]) do
  {:ok, %__MODULE__{}}
end
  
def import(license) do
  GenServer.cast(LicenseServer, {:import, license})
end

def handle_call(:show,_, state) do
{:reply, state, state}
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
  
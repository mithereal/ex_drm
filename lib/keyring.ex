defmodule License.Keyring do
    use GenServer

    defstruct licenses: []

    def start_link(init \\ []) do
  
      GenServer.start_link(__MODULE__, init, name: License.Keyring)
    end
  
def valid?(license) do
  
end


def show() do
  GenServer.call(License.Keyring, :show)
end

def init([]) do
  {:ok, %__MODULE__{}}
end
  
def import(license) do
  GenServer.cast(License.Keyring, {:import, license})
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
  
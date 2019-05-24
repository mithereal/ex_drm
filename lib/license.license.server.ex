defmodule License.License.Server do
use GenServer

defstruct meta: %{}, 
          policy: %{}


def start_link(init \\ [%{meta: ${}, policy: %{}}]) do
  
    GenServer.start_link(__MODULE__, init, name: License.License.Server)
  end

    
  
  def init([license]) do
    send(self(), {:setup, license) 
    {:ok, %__MODULE__{license}}
  end
    
  def handle_info({:setup, license} ,_, state) do
   ## create proceess for each licennse key, and setup a socket so the client can connect, this will allow for seeing how many concurent connections we have, and how ot deal with license violations
   # License.ChannelSupervisor.start_link()
  {:reply, :ok , state}
  end
  
  end
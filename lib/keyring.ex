defmodule Drm.Key.Ring do

   @moduledoc false

   alias License.Key.Server, as: KEYSERVER
   

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
  GenServer.call(KEYSERVER, {:exists, license})
end

def remove{license} do
  GenServer.call(KEYSERVER, {:remove, license})
end

def list() do
  GenServer.call(KEYSERVER, :list)
end

def export(id) do
  GenServer.call(KEYSERVER, {:export, id})
end

def init([]) do
  {:ok, nil}
end
  
def import(license) do
  GenServer.cast(KEYSERVER, {:import, license})
end


end
  
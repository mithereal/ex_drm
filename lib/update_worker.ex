defmodule Drm.UpdateWorker do
## this represents a remote client to join the license channel and send the join msg
    @moduledoc false
 
    use GenServer
  
    require Logger

    alias Drm.Licenses

 @name __MODULE__
 
 
   def child_spec(_) do
     %{
       id: __MODULE__,
       start: {__MODULE__, :start_link, []},
       type: :worker
     }
   end          
 
 def start_link(data) do
   
     GenServer.start_link(__MODULE__, data, name: @name)
   end

   @spec init(:ok) :: {:ok, Licenses.t} | {:stop, any}
   def init(:ok) do
    Process.send_after(self(), :refresh, get_refresh_interval())
    case refresh() do
      {:ok, licenses} -> {:ok, licenses}
      {:error, binary} -> {:stop, {:error, binary}}
    end
       {:ok, __MODULE__ }
   end

   @spec handle_call(:get, any, Licenses.t) :: {:reply, Licenses.t, Licenses.t}
   def handle_call(:get, _options, state) do
     {:reply, state, state}
   end

   @spec handle_info(:refresh, Licenses.t) :: {:noreply, Licenses.t}
   def handle_info(:refresh, state) do
     Process.send_after(self(), :refresh, get_refresh_interval())
     case refresh() do
       {:ok, licenses} -> {:noreply, licenses}
       {:error, _} -> {:noreply, state}
     end
   end

  defp refresh do
    case sync() do
      {:ok, licenses} ->
        Logger.info "Refreshed Licenses."
        Logger.debug inspect(licenses)
        {:ok, licenses}
      {:error, error} ->
        Logger.error "An error occured while rereshing licenses. " <> inspect(error)
        {:error, error}
    end
  end

  @spec get_source() :: atom
  defp sync, do: 
  licenses = Drm.Key.Ring.list()
  source = Application.get_env(:drm, :source)

  Enum.each(licenses, fn(l) -> 
  ## connect to remote server and fetch the license
  end)
end
  # Default: One Day
  @spec get_refresh_interval() :: integer
  defp get_refresh_interval, do: Application.get_env(:drm, :refresh_interval, 1000 * 60 * 60 * 24)

  @spec get_licenses() :: Licenses.t
  def get_licenses, do: GenServer.call(@update_worker, :get)
end
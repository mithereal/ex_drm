defmodule Drm.Client do
## this represents a remote client to join the license channel and send the join msg
    @moduledoc false
    
 @name __MODULE__
 
 alias Drm.Hub, as: HUB
 
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

   def init(data) do
    #HUB.subscribe(data.hash)
    HUB.publish(data.hash, "join")
       {:ok, __MODULE__ }
   end
end
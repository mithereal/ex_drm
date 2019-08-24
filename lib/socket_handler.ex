defmodule Drm.SocketHandler do
  @behaviour :cowboy_websocket
  @timeout 60000

  defmodule EventHandler do
    @behaviour :gen_event
    require Logger

    def init(_state) do
      :ok
    end

    def handle_event(_, parent) do
      {:ok, parent}
    end

    def handle_call(_, parent) do
      {:ok, parent}
    end

    def terminate(reason, _parent) do
      Logger.info("Socket EventHandler Terminating: #{inspect(reason)}")
      :ok
    end
  end

  def init(ref, state) do
    {:cowboy_websocket, ref, state}
  end

  def websocket_init(_state) do
    state = %{}
    {:ok, state}
  end

  def websocket_handle({:text, message}, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_handle({:text, msg}, state) do
    decoded = Jason.decode!(msg)
    # TODO: case run different funs based on msg body 
    users = Drm.License.Supervisor.get_users()
    {:reply, {:text, users}, state}
  end

  def websocket_info(_info, state) do
    {:reply, state}
  end

  def websocket_info(:shutdown, req, state) do
    {:shutdown, req, state}
  end

  def websocket_terminate(_reason, _req, _state), do: :ok
end

defmodule Drm.SocketHandler do
  @behaviour :cowboy_websocket_handler
  @timeout 60000

  defmodule EventHandler do
    use GenEvent
    require Logger

    def handle_event(_, parent) do
      {:ok, parent}
    end

    def terminate(reason, parent) do
      Logger.info("Socket EventHandler Terminating: #{inspect(reason)}")
      :ok
    end
  end

  def init(_, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_type, req, _opts) do
    {:ok, req, %{}, @timeout}
  end

  def websocket_handle({:text, message}, req, state) do
    {:reply, {:text, message}, req, state}
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end

  def websocket_info(:shutdown, req, state) do
    {:shutdown, req, state}
  end

  def websocket_terminate(_reason, _req, _state), do: :ok
end

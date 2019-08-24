defmodule Drm.WebSocket do
  use WebSockex
  require Logger

  def start_link(url, state) do
    url = "wss://" <> url

    WebSockex.start_link(url, __MODULE__, state,
      ssl_options: [
        ciphers: :ssl.cipher_suites() ++ [{:rsa, :aes_128_cbc, :sha}]
      ]
    )
  end

  @spec echo(pid, String.t()) :: :ok
  def echo(client, message) do
    Logger.info("Sending message: #{message}")
    WebSockex.send_frame(client, {:text, message})
  end

  def handle_frame({type, msg}, state) do
    IO.puts("Received Message - Type: #{inspect(type)} -- Message: #{inspect(msg)}")
    {:ok, state}
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected to Websocket!")
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect(reason)}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

  def terminate(reason, state) do
    # IO.puts(\nSocket Terminating:\n#{inspect reason}\n\n#{inspect state}\n")
    exit(:normal)
  end
end

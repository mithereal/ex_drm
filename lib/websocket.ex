defmodule Drm.WebSocket do
    use WebSockex
  
    def start_link(url, state) do
      WebSockex.start_link(url, __MODULE__, state,
      ssl_options: [
        ciphers: :ssl.cipher_suites() ++ [{:rsa, :aes_128_cbc, :sha}]
      ])
    end
  
    def handle_frame({type, msg}, state) do
      IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
      {:ok, state}
    end
  
    def handle_cast({:send, {type, msg} = frame}, state) do
      IO.puts "Sending #{type} frame with payload: #{msg}"
      {:reply, frame, state}
    end

    def terminate(reason, state) do
       #IO.puts(\nSocket Terminating:\n#{inspect reason}\n\n#{inspect state}\n")
        exit(:normal)
    end
  end
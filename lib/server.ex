defmodule Drm.Server do
  use GenServer

  @moduledoc false

  @derive {Jason.Encoder, only: [:hash, :meta, :policy, :connections, :status]}

  @registry_name :license_registry
  @name __MODULE__



  defstruct filename: "",
            hash: "",
            meta: %{},
            policy: %{},
            connections: 0,
            max_floats: 0,
            status: :ok

  def child_spec(license) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [license]},
      type: :worker
    }
  end

  def start_link(data \\ [%{filename: "", hash: "", meta: %{}, policy: %{}}]) do
    name = via_tuple(data.hash)
    GenServer.start_link(__MODULE__, data, name: name)
  end

  def init(license) do

    filename =
      case Map.has_key?(license, :filename) do
        true -> license.filename
        false -> ""
      end


    {
      :ok,
      %__MODULE__{
        filename: filename,
        hash: license.hash,
        meta: license.meta,
        policy: license.policy,
        connections: 0,
        max_floats:  Application.get_env(:drm, :max_floats, 0),
        status: :ok
      }
    }
  end


  def handle_info(:join, state) do
    connections = state.connections + 1

    status =
      reply = case state.policy.validation_type do
        "strict" ->
          case connections > state.max_fingerprints do
            true -> {:error, "license limit exceeded"} ## broadcast to user
            false -> {:ok, "valid license"}
          end

        "floating" ->
          float_num = state.max_fingerprints + state.max_floats

          case state.connections do
            x when x > float_num ->  {:ok, "valid license"}
            _ -> {:error, "license limit exceeded"}
          end
      end


      state  = %{state | connections: connections}
           state =  %{state | status: status}


    {:noreply, state}
  end

  def handle_info(:leave, state) do
    connections = state.connections - 1

    status =
      reply = case state.policy.validation_type do
        "strict" ->
          case connections > state.max_fingerprints do
            true -> {:error, "license limit exceeded"}
            false -> {:ok, "valid license"}
          end

        "floating" ->
          float_num = state.max_fingerprints + state.max_floats

          case state.connections do
            x when x > float_num ->  {:ok, "valid license"}
            _ -> {:error, "license limit exceeded"}
          end

      end


      state  = %{state | connections: connections}
           state =  %{state | status: status}


    {:noreply, state}
  end

  def handle_call(:show, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:invalidate, _from, state) do
  state = %{state | status: :error}
    {:reply, state, state}
  end

  def handle_call(:validate, _from, state) do
  state = %{state | status: :ok}
    {:reply, state, state}
  end

  def invalidate(hash) do
     GenServer.call(via_tuple(hash), :invalidate)
  end

  def validate(hash) do
     GenServer.call(via_tuple(hash), :validate)
  end

  defp via_tuple(name) do
    {:via, Registry, {@registry_name, name}}
  end
end

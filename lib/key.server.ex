defmodule Drm.Key.Server do
  @moduledoc false

  alias Drm.Key.Server, as: KEYSERVER
  alias Drm.License.Supervisor, as: LICENSESUPERVISOR

  defstruct licenses: []

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker
    }
  end

  def start_link(init \\ []) do
    GenServer.start_link(__MODULE__, init, name: KEYSERVER)
  end

  def exists?(license) do
    GenServer.call(KEYSERVER, {:exists, license})
  end

  def remove({license}) do
    GenServer.call(KEYSERVER, {:remove, license})
  end

  def list() do
    GenServer.call(KEYSERVER, :list)
  end

  def init([]) do
    LICENSESUPERVISOR.start_link()
    {:ok, %__MODULE__{}}
  end

  def import(license) do
    GenServer.cast(KEYSERVER, {:import, license})
  end

  def start_licenses() do
    GenServer.cast(KEYSERVER, :start_licenses)
  end

  def export(id) do
    GenServer.call(KEYSERVER, {:export, id})
  end

  def clear do
    GenServer.call(KEYSERVER, :clear)
  end

  def handle_call({:export, id}, _, state) do
    export = Enum.reject(state.licenses, fn x -> x.policy.fingerprint != id end)
    {:reply, export, state}
  end

  def handle_call(:list, _, state) do
    {:reply, state.licenses, state}
  end

  def handle_call({:exists, license}, _, state) do
    exists = Enum.member?(state.licenses, license)
    {:reply, exists, state}
  end

  def handle_call(:clear, _, state) do
    {:reply, :ok, []}
  end

  def handle_call({:remove, license}, _, state) do
    licenses = Enum.reject(state.licenses, fn l -> l = license end)

    {:reply, :ok,
     %__MODULE__{
       state
       | licenses: licenses
     }}
  end

  def handle_cast(:start_licenses, state) do
    Enum.each(state.licenses, fn x ->
      LICENSESUPERVISOR.start_child(x)
    end)

    {:noreply, state}
  end

  def handle_cast({:start_license, license}, state) do
    LICENSESUPERVISOR.start_child(license)

    {:noreply, state}
  end

  def handle_cast({:import, license}, state) do
    licenses = state.licenses ++ [license]
    # GenServer.cast(KEYSERVER, {:start_license,license)
    {:noreply,
     %__MODULE__{
       state
       | licenses: licenses
     }}
  end
end

defmodule License.License.Supervisor do
    use Supervisor
    require Logger
  
  @registry_name :license_registry
  
  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end
  
  def start(id) do
    Supervisor.start_child(__MODULE__, [ id ])
  end
  
  def stop(id) do
    case Registry.lookup(@registry_name, id) do
      [] -> :ok
      [{pid, _}] ->
        Process.exit(pid, :shutdown)
        :ok
    end
  end
  
  def init(_) do
    children = [worker(License.License.Server, [], restart: :transient)]
    supervise(children, [strategy: :simple_one_for_one])
  end
  
  def find_or_create_process(id)  do
     if process_exists?(id) do
       {:ok, id}
     else
       quote_id |> start_quote
     end
  end
  
  def process_exists?(id)  do
    case Registry.lookup(@registry_name, id) do
      [] -> false
      _ -> true
    end
  end
  
  def ids do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, account_proc_pid, _, _} ->
      Registry.keys(@registry_name, account_proc_pid)
      |> List.first
    end)
    |> Enum.sort
  end
  end
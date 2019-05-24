defmodule License.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias License.Keyring
  alias License.Server

  def start(_type, _args) do
    import Supervisor.Spec

    mode = Application.get_env(:license,:mode)

    children = case mode do
      "keyring" -> [Keyring,worker(Task, [&load/0], restart: :transient)]
      "keyserver" -> [Keyring,Server,supervisor(Registry, [:unique, :license_registry], id: :license_registry),worker(Task, [&load/0], restart: :transient)]
      "both" -> [Keyring,Server,supervisor(Registry, [:unique, :license_registry], id: :license_registry),worker(Task, [&load/0], restart: :transient)]
       _-> [Keyring,worker(Task, [&load/0], restart: :transient)]
    end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: License.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def load() do
    mode = Application.get_env(:license,:mode)

    files = Path.wildcard(Application.get_env(:license,:path) <> "/*.key")

    Enum.each(files, fn(f) ->
      {_, encoded } = File.read f

      decoded = License.decode encoded

       case mode do
        "keyring" -> Keyring.import decoded
        "keyserver" -> Server.import decoded
        "both" -> Keyring.import decoded
                  Server.import decoded
        _ -> Keyring.import decoded
       end
      
    end)
  end
end

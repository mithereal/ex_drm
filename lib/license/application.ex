defmodule Drm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Drm, as: License
  alias Drm.Key.Ring, as: KEYRING
  alias Drm.Key.Server, as: KEYSERVER

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      License.ChannelRegistry,
      supervisor(Registry, [:unique, :license_registry], id: :license_registry),
      KEYRING,
      KEYSERVER,
      worker(Task, [&load/0], restart: :transient)
    ]


    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: License.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def load() do

    files = Path.wildcard(Application.get_env(:drm,:path) <> "/*.key")

    Enum.each(files, fn(f) ->
      {_, encoded } = File.read f

      IO.inspect encoded

      decoded = License.decode encoded

      case decoded do
        nil -> nil
        _-> KEYSERVER.import decoded
      end

      
    end)

    KEYSERVER.start_licenses
  end
end

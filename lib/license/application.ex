defmodule Drm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Drm, as: License
  alias Drm.LicenseRegistry, as: LICENSEREGISTRY
  alias Drm.License.Supervisor, as: LICENSESUPERVISOR

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      LICENSEREGISTRY,
      LICENSESUPERVISOR,
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Drm.Router,
        options: [
          dispatch: dispatch(),
          port: 4000
        ]
      ),
      worker(Task, [&load/0], restart: :transient),
      worker(Drm.UpdateWorker, [], restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: License.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def load() do
    files = Path.wildcard(Application.get_env(:drm, :path) <> "/*.key")

    Enum.each(files, fn f ->
      {_, encoded} = File.read(f)

      {_, decoded} = License.decode(encoded)

      case decoded do
        nil ->
          nil

        _ ->
          new_license = new_license = Map.put(decoded, :filename, f)
          LICENSESUPERVISOR.start_child(new_license)
      end
    end)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws/[...]", Drm.SocketHandler, []},
         {:_, Plug.Cowboy.Handler, {Drm.Router, []}}
       ]}
    ]
  end
end

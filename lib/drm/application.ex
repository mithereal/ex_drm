defmodule Drm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @default_path  Path.expand("../../priv/license", __DIR__)

  def start(_type, _args) do

    children = [
      Drm.Registry,
      Drm.License.Supervisor,
      Drm.Vault,
      Drm.Updater
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Drm.Supervisor]

    link = Supervisor.start_link(children, opts)

    load()

    link
  end

  def load() do

    files = Path.wildcard(Application.get_env(:drm, :path, @default_path) <> "/*.key")

    Enum.each(
      files,
      fn f ->
        {_, encoded} = File.read(f)

        {_, decoded} = Drm.decode(encoded)

        case decoded do
          nil ->
            nil

          _ ->
            new_license = new_license = Map.put(decoded, :filename, f)
            Drm.License.Supervisor.start_child(new_license)
        end
      end
    )
  end
end

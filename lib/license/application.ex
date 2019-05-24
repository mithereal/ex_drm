defmodule License.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias License.Keyring

  def start(_type, _args) do
    import Supervisor.Spec
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: License.Worker.start_link(arg)
      Keyring,
      worker(Task, [&load/0], restart: :transient)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: License.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def load() do
    files = Path.wildcard(Application.get_env(:license,:path) <> "/*.key")
    Enum.each(files, fn(f) ->
      {_, encoded } = File.read f
      decoded = License.decode encoded
      Keyring.import decoded
    end)
  end
end

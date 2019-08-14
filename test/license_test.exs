defmodule DrmTest do
  use ExUnit.Case
  alias Drm, as: License
  alias Drm.Key.Ring, as: KEYRING
  alias Drm.Key.Server, as: KEYSERVER
  alias Drm.License.Supervisor, as: LICENSESUPERVISOR

  # use Drm.RepoCase
  doctest Drm

  test "start the server for this key then we can dispatch incoming requests to it, to validate" do
    files = Path.wildcard(Application.get_env(:drm, :path) <> "/*.key")

    decoded =
      case Enum.count(files) > 0 do
        true ->
          {_, encoded} = File.read(List.first(files))
          License.decode(encoded)

        false ->
          :error
      end

    status =
      case decoded != :error do
        true ->
          {status, _} = LICENSESUPERVISOR.start_child(decoded)
          status

        false ->
          :error
      end

    assert status == :ok
  end
end

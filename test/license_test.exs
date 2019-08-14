defmodule DrmTest do
  use ExUnit.Case
  alias Drm, as: License
  alias Drm.Key.Ring, as: KEYRING
  alias Drm.Key.Server, as: KEYSERVER
  alias Drm.License.Supervisor, as: LICENSESUPERVISOR

  # use Drm.RepoCase
  # doctest Drm

  test "Create a license" do
    files = Path.wildcard(Application.get_env(:drm, :path) <> "/*.key")
    {_, encoded} = File.read(List.first(files))
    decoded = License.decode(encoded)
    {status, _} = LICENSESUPERVISOR.start_child(decoded)
    assert status == :ok
  end

  test "start the server for this key then we can dispatch incoming requests to it, to validate" do
    files = Path.wildcard(Application.get_env(:drm, :path) <> "/*.key")
    {_, encoded} = File.read(List.first(files))
    decoded = License.decode(encoded)
    {status, _} = LICENSESUPERVISOR.start_child(decoded)
    assert status == :ok
  end
end

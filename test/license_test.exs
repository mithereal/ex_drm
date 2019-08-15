defmodule DrmTest do
  use ExUnit.Case
  alias Drm, as: License
  alias Drm.Key.Ring, as: KEYRING
  alias Drm.Key.Server, as: KEYSERVER
  alias Drm.License.Supervisor, as: LICENSESUPERVISOR

  # use Drm.RepoCase
  doctest Drm
end

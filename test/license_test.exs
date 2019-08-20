defmodule DrmTest do
  use ExUnit.Case
  alias Drm, as: License
  alias Drm.Key.Ring, as: KEYRING
  alias Drm.Key.Server, as: KEYSERVER
  alias Drm.License.Supervisor, as: LICENSESUPERVISOR

  # use Drm.RepoCase
  doctest Drm

  test "Create a new License" do
    license = %{
      hash: "license-key",
      meta: %{email: "demo@example.com", name: "licensee name"},
      policy: %{
        name: "policy name",
        type: "free",
        expiration: nil,
        validation_type: "strict",
        checkin: false,
        checkin_interval: nil,
        max_fingerprints: nil,
        fingerprint: "main-app-name-umbrella-app-hash-id"
      }
    }

    encrypted_license = License.create(license)

    assert String.length(encrypted_license) != 0

    ## check if process is registered
    ## assert(:not_found != Drm.LicenseRegistry.lookup(license.hash))
  end
end

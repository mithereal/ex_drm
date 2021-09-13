defmodule DrmTest do
  use ExUnit.Case
  alias Drm, as: License

  # use Drm.RepoCase
  #doctest Drm

  test "Create a valid License" do
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
    assert(:not_found != Drm.Registry.lookup(license.hash))
    assert(true == License.is_valid?(license))
  end

  test "Create an invalid License" do
    license = %{
      hash: "commercial-license-key",
      meta: %{email: "demo@example.com", name: "licensee name"},
      policy: %{
        name: "policy name",
        type: "commercial",
        expiration: 1,
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
    assert(:not_found != Drm.Registry.lookup(license.hash))

    assert(false == License.is_valid?(license))
  end
end

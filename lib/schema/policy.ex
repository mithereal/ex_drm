defmodule Drm.Schema.Policy do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "policy" do
    field(:checkin, :boolean)
    field(:checkin_interval, :boolean)
    field(:expiration, :integer)
    field(:fingerprint, :string)
    field(:max_fingerprints, :integer)
    field(:name, :string)
    field(:type, :string)
    field(:validation_type, :string)
  end

  def from_json(%{
        "checkin" => checkin,
        "checkin_interval" => checkin_interval,
        "expiration" => expiration,
        "fingerprint" => fingerprint,
        "max_fingerprints" => max_fingerprints,
        "name" => name,
        "type" => type,
        "validation_type" => validation_type
      }) do
    %{
      checkin: checkin,
      checkin_interval: checkin_interval,
      expiration: expiration,
      fingerprint: fingerprint,
      max_fingerprints: max_fingerprints,
      name: name,
      type: type,
      validation_type: validation_type
    }
  end
end

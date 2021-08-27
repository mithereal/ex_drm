defmodule Drm.Schema.Policy do
  @moduledoc false

defstruct checkin: nil,
      checkin_interval: nil,
      expiration: nil,
      fingerprint: nil,
      max_fingerprints: nil,
      name: nil,
      type: nil,
      validation_type: nil

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
    %Drm.Schema.Policy{
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

    def to_json(%{
         "checkin" => checkin,
        "checkin_interval" => checkin_interval,
        "expiration" => expiration,
        "fingerprint" => fingerprint,
        "max_fingerprints" => max_fingerprints,
        "name" => name,
        "type" => type,
        "validation_type" => validation_type
      }) do
    struct = %Drm.Schema.Policy{
      checkin: checkin,
      checkin_interval: checkin_interval,
      expiration: expiration,
      fingerprint: fingerprint,
      max_fingerprints: max_fingerprints,
      name: name,
      type: type,
      validation_type: validation_type
    }
    Jason.encode!(struct)
  end
end

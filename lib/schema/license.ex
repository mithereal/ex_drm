defmodule Drm.Schema.License do
  @moduledoc false

  defstruct license: nil,
    hash: nil,
    meta: nil,
    policy: nil

  def from_json(%{
        "hash" => hash,
        "meta" => meta,
        "policy" => policy
      }) do
    %Drm.Schema.License{
      hash: hash,
      meta: Drm.Schema.Meta.from_json(meta),
      policy: Drm.Schema.Policy.from_json(policy)
    }
  end

  def to_json(%{
        "hash" => hash,
        "meta" => meta,
        "policy" => policy
      }) do
    struct = %Drm.Schema.License{
      hash: hash,
      meta: Drm.Schema.Meta.to_json(meta),
      policy: Drm.Schema.Policy.to_json(policy)
    }
    Jason.encode!(struct)
  end

end

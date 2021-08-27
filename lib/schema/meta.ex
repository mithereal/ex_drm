defmodule Drm.Schema.Meta do
  @moduledoc false

  defstruct  email: nil,
    name: nil


  def from_json(%{
        "email" => email,
        "name" => name
      }) do
    %Drm.Schema.Meta{
      email: email,
      name: name
    }
  end

  def to_json(%{
        "email" => email,
        "name" => name
      }) do
    struct = %Drm.Schema.Meta{
      email: email,
      name: name
    }
    Jason.encode!(struct)
  end

end

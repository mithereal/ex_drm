defmodule Drm.Schema.Meta do
  use Ecto.Schema
  import Ecto.Changeset

  schema "meta" do
    field(:email, :string)
    field(:name, :string)
  end

  def from_json(%{
        "email" => email,
        "name" => name
      }) do
    %{
      email: email,
      name: name
    }
  end
end

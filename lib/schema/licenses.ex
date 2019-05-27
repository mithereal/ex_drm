defmodule Drm.Licenses do

    use Ecto.Schema
  
    import Ecto.Changeset
    import Ecto.Query
  
    alias Drm.Schema.License, as: LICENSE
    alias Drm.Schema.User, as: USER
  
    @moduledoc false
    schema "licenses" do
      belongs_to(:user, USER)
      belongs_to(:license, LICENSE)
    end
  
    @params ~w(license_id user_id license user)a
    @required_fields ~w()a
  
    @doc """
    Builds a changeset based on the `struct` and `params`.
    """
  
    def changeset(struct, params) do
      struct
      |> cast(params, @params)
      |> cast_assoc(:license)
      |> cast_assoc(:user)
    end
  
  end
  
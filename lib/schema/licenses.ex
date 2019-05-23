defmodule DB.Schema.Company.Users do

    use Ecto.Schema
  
    import Ecto.Changeset
    import Ecto.Query
  
    alias License.Schema.License, as: LICENSE
    alias License.Schema.User, as: USER
  
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
  
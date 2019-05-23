
defmodule License.Schema.License do
  use Ecto.Schema
  import Ecto.Changeset

  alias License.Schema.License

  @derive {Jason.Encoder, only: [:meta, :policy]}
  schema "license" do

    field :meta, :map
    field :policy, :map
  end

  @params ~w(meta policy)a
  @required_fields ~w(meta policy)a

  @doc """
  Creates a changeset 
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required_fields)
  end

  ## strict, floating and concurrent are validation types
  ## strict: a license that implements the policy will be considered invalid if its machine limit is surpassed
  ## floating: a license that implements the policy will be valid across multiple machines
  ## concurrent: a licensing model, where you allow a set number of machines to be activated at one time, and exceeding that limit may invalidate all current sessions.
  def create(license \\ %{meta: %{email: "user@example.com", name: "company name" }, policy: %{type: "free", expiration: nil, validation_type: "strict", checkin: false, checkin_interval: nil, max_fingerprints: nil, fingerprint: "umbrella-app-hash-id"}}) do
    

    changeset = License.changeset(%License{}, license)
    
   Ecto.Changeset.apply_changes(changeset)

end

end

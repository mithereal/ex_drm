
defmodule Drm.Schema.License do

   @moduledoc false
   
  use Ecto.Schema
  import Ecto.Changeset

  alias Drm.Schema.License

  @derive {Jason.Encoder, only: [:hash, :meta, :policy]}
  schema "license" do

    field :hash, :string
    field :meta, :map
    field :policy, :map
  end

  @params ~w(hash meta policy)a
  @required_fields ~w(hash meta policy)a

  @doc """
  Creates a changeset 
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required_fields)
  end

  
  def create(%{hash: hash, meta: meta, policy: policy}) do

    changeset = License.changeset(%License{}, %{hash: hash, meta: meta, policy: policy})
    
   Ecto.Changeset.apply_changes(changeset)

end

end

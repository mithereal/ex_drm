
defmodule Drm.Schema.License do

   @moduledoc false
   
  use Ecto.Schema
  import Ecto.Changeset

  alias Drm.Schema.License

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

  
  def create(%{meta: meta, policy: policy}) do

    changeset = License.changeset(%License{}, %{meta: meta, policy: policy})
    
   Ecto.Changeset.apply_changes(changeset)

end

end

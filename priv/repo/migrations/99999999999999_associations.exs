defmodule DB.Repo.Migrations.License.Associations do
  use Ecto.Migration

  def change do
    alter table(:licenses) do
      add(:license_id, references(:license, on_delete: :nothing))
      add(:user_id, references(:license_user, on_delete: :nothing))
    end
  end
end

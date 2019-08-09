defmodule DB.Repo.Migrations.License.User do
  use Ecto.Migration

  def change do
    create table(:license_users) do
      add(:email, :binary)
      add(:email_hash, :binary)
      add(:user, :binary)
      add(:password_hash, :binary)
      add(:key_id, :integer)

      timestamps()
    end

    create(unique_index(:license_users, [:email_hash]))
  end

  def down do
    execute("DROP license_users")
  end
end

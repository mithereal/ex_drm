defmodule DB.Repo.Migrations.License do
  use Ecto.Migration

  def change do
    create table(:license) do
      add(:hash, :binary)
    end
  end

  def down do
    execute("DROP license")
  end
end

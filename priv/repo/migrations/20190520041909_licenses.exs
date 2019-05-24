defmodule DB.Repo.Migrations.Licenses do
  use Ecto.Migration

  def change do
    create table(:licenses) do
          
    end
    ) 
  end

  def down do
    execute "DROP licenses"
  end
end

defmodule ShortLinks.Repo.Migrations.AddLinksTable do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :slug, :string, null: false, size: 8, collate: :nocase
      add :destination, :string, null: false, collate: :nocase

      timestamps()
    end

    create unique_index(:links, [:slug])
  end
end

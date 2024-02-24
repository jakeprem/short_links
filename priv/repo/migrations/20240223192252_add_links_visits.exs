defmodule ShortLinks.Repo.Migrations.AddLinksVisits do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add :visits, :integer, default: 0
    end
  end
end

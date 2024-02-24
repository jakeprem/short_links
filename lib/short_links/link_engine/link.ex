defmodule ShortLinks.LinkEngine.Link do
  use Ecto.Schema

  import Ecto.Changeset
  import ShortLinks.Ecto.Validators, only: [validate_url: 2]

  schema "links" do
    field :slug, :string
    field :destination, :string
    field :visits, :integer, default: 0

    timestamps()
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:destination, :slug, :visits])
    |> validate_required([:destination, :slug])
    |> validate_url(:destination)
    |> unique_constraint(:slug)
  end
end

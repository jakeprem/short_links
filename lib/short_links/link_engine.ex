defmodule ShortLinks.LinkEngine do
  @moduledoc """
  The main context module for interacting with links.

  Naming these things is always hard in small projects, but I think
  LinkEngine is a pretty good description of the funcitonality.
  """

  alias ShortLinks.LinkEngine.Link
  alias ShortLinks.Repo

  @alphanumeric_characters "abcdefghijklmnopqrstuvwxyz123456789"
  @doc """
  Generate a random 8 character slug to be used in a short link.

  Valid characters are a-z and 1-9.
  """
  def generate_slug do
    Nanoid.generate(8, @alphanumeric_characters)
  end

  @doc """
  Create a new link for the given destination.

  ## Examples

      iex> create_link(%{destination: "https://example.com", slug: "abcd1234"})
      {:ok, %Link{}}

      iex> create_link(%{destination: "missing-or-malformed"})
      {:error, %Ecto.Changeset{}}
  """
  def create_link(attrs \\ %{}) do
    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `Ecto.Changeset` for the given link with the given attributes.

  ## Examples

      iex> link = link_fixture(link)
      %Ecto.Changeset{data: %Link{}}
  """
  def change_link(link, attrs \\ %{}) do
    Link.changeset(link, attrs)
  end

  @doc """
  Get a single link by its id.

  Returns nil if the Link is not found.

  ## Examples

      iex> get_link(1)
      %Link{}

      iex> get_link(999)
      nil
  """
  def get_link(id) do
    Repo.get(Link, id)
  end

  @doc """
  List all links.
  """
  def list_links do
    Repo.all(Link)
  end
end

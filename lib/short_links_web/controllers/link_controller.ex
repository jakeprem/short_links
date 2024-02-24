defmodule ShortLinksWeb.LinkController do
  use ShortLinksWeb, :controller

  alias ShortLinks.LinkEngine
  alias ShortLinks.LinkEngine.Link

  def new(conn, _params) do
    changeset = LinkEngine.change_link(%Link{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"link" => link_params}) do
    link_params = Map.put(link_params, "slug", LinkEngine.generate_slug())

    case create_link_with_slug(link_params) do
      {:ok, link} ->
        conn
        |> put_flash(:info, "Link created successfully.")
        |> redirect(to: ~p"/stats/#{link.slug}")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  # Not sure if I want to keep the slug generation here or not.
  defp create_link_with_slug(attrs) do
    attrs
    |> Map.put("slug", LinkEngine.generate_slug())
    |> LinkEngine.create_link()
    |> case do
      {:error, %{errors: [slug: {"has already been taken", _}]}} -> create_link_with_slug(attrs)
      result -> result
    end
  end

  def show(conn, %{"slug" => slug}) do
    case LinkEngine.get_link_by_slug(slug) do
      nil ->
        conn
        |> put_flash(:error, "Link not found.")
        |> redirect(to: ~p"/")

      link ->
        render(conn, :show, link: link)
    end
  end

  def stats(conn, _params) do
    links = LinkEngine.list_links()
    render(conn, :stats, links: links)
  end
end

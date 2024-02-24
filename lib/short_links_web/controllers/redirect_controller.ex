defmodule ShortLinksWeb.RedirectController do
  use ShortLinksWeb, :controller

  alias ShortLinks.LinkEngine

  def execute_link(conn, %{"slug" => slug}) do
    case LinkEngine.get_link_by_slug(slug) do
      nil -> conn |> put_flash(:error, "Link not found") |> put_status(302) |> redirect(to: ~p"/")
      link -> conn |> redirect(external: link.destination)
    end
  end
end

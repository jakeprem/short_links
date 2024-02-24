defmodule ShortLinksWeb.RedirectController do
  use ShortLinksWeb, :controller

  alias ShortLinks.LinkEngine

  def execute_link(conn, %{"slug" => slug}) do
    case LinkEngine.get_link_by_slug(slug) do
      nil ->
        conn |> put_status(302) |> redirect(to: ~p"/")

      link ->
        # Ignoring the return since we don't want to block the user
        # if something goes wrong.
        #
        # From benchmarking, running this in a task doesn't seem to
        # benefit performance much when under load, and latencies are
        # low enough that it's not worth worrying about right now.
        #
        # In a high traffic system this would probably be a suboptimal
        # choice.
        LinkEngine.increment_link_visits(link)

        conn |> redirect(external: link.destination)
    end
  end
end

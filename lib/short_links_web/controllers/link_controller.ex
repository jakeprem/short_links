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
        |> redirect(to: ~p"/")

      link ->
        render(conn, :show, link: link)
    end
  end

  def stats(conn, _params) do
    links = LinkEngine.list_links()
    render(conn, :stats, links: links)
  end

  def stats_csv(conn, _) do
    # The implicit coupling of the slug to the route here isn't great.
    # This would be a good thing to refactor.
    conn_url = url(~p"/")

    # Ideally we'd stream the whole list of links rather than load them all into memory.
    # However, Repo.stream/2 needs to run in a transaction which has tradeoffs.
    # Alternatively could be implemented using Stream.resource/3, which some tradeoffs around
    # when data changes, but they shouldn't impact this use case too much.
    link_csv_stream =
      LinkEngine.list_links() |> LinkEngine.CSVExporter.get_links_csv_stream(conn_url)

    chunked_conn =
      conn
      |> put_resp_content_type("text/csv")
      |> send_chunked(200)

    Enum.reduce_while(link_csv_stream, chunked_conn, fn chunk, conn ->
      case Plug.Conn.chunk(conn, chunk) do
        {:ok, conn} -> {:cont, conn}
        {:error, _} -> {:halt, conn}
      end
    end)
  end
end

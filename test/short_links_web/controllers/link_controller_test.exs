defmodule ShortLinksWeb.PageControllerTest do
  alias ShortLinks.LinkEngine
  use ShortLinksWeb.ConnCase

  import ShortLinks.LinkEngineFixtures, only: [link_fixture: 0, link_fixture: 1]

  @create_attrs %{destination: "http://example.com"}
  @invalid_attrs %{destination: "invalid-url"}

  describe "new" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "New Link"
    end
  end

  describe "create link" do
    test "redirects to stats/:slug when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/", link: @create_attrs)

      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/stats/#{slug}"

      conn = get(conn, ~p"/stats/#{slug}")
      assert html_response(conn, 200) =~ "Here's your link:"
    end

    test "slug is generated automatically in controller", %{conn: conn} do
      conn = post(conn, ~p"/", link: @create_attrs)

      assert %{slug: slug} = redirected_params(conn)
      link = LinkEngine.get_link_by_slug(slug)
      assert link.slug not in [nil, ""]
    end

    test "returns an error if the destination is missing or malformed", %{conn: conn} do
      conn = post(conn, ~p"/", link: @invalid_attrs)
      assert html_response(conn, 200) =~ "invalid URL, no scheme given"
    end
  end

  describe "show" do
    test "renders link", %{conn: conn} do
      link = link_fixture()
      conn = get(conn, ~p"/stats/#{link.slug}")

      assert html_response(conn, 200) =~ unverified_url(conn, "/#{link.slug}")
    end

    test "redirects to / when link is not found", %{conn: conn} do
      conn = get(conn, ~p"/stats/999")
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "stats" do
    test "renders stats", %{conn: conn} do
      links = Enum.map(1..3, fn num -> link_fixture(%{visits: num}) end)
      conn = get(conn, ~p"/stats")

      assert html_response(conn, 200) =~ "Link Stats"

      for link <- links do
        assert html_response(conn, 200) =~ link.destination
        assert html_response(conn, 200) =~ link.slug
        # link.count
        assert html_response(conn, 200) =~ to_string(link.visits)
      end
    end
  end

  describe "stats_csv" do
    test "returns a CSV file", %{conn: conn} do
      links = Enum.map(1..3, fn num -> link_fixture(%{visits: num}) end)
      conn = get(conn, ~p"/stats/csv")

      assert resp_header(conn, "content-type") =~ "text/csv"

      parsed_links = LinkEngine.CSVExporter.parse_links_csv(conn.resp_body)

      expected_links =
        links
        |> Enum.map(fn link ->
          [
            # Here's that unfortunate coupling again 😅
            "http://localhost:4002/#{link.slug}",
            link.destination,
            to_string(link.visits),
            "#{link.inserted_at}"
          ]
        end)
        |> Enum.reverse()

      assert parsed_links == expected_links
    end
  end

  defp resp_header(conn, key) do
    case Enum.find(conn.resp_headers, fn {k, _} -> k == key end) do
      {_, v} -> v
      nil -> nil
    end
  end
end

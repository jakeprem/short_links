defmodule ShortLinksWeb.RedirectControllerTest do
  use ShortLinksWeb.ConnCase

  import ShortLinks.LinkEngineFixtures, only: [link_fixture: 0, link_fixture: 1]

  alias ShortLinks.LinkEngine

  describe "execute link" do
    test "redirects to the link's destination", %{conn: conn} do
      link = link_fixture(%{destination: "https://elixir-lang.org"})
      conn = get(conn, "/#{link.slug}")

      assert redirected_to(conn, 302) == link.destination
    end

    test "works with query params, path, and fragment", %{conn: conn} do
      destination_url = "http://subdomain.example.com?query=param#fragment"
      link = link_fixture(%{destination: destination_url})
      conn = get(conn, "/#{link.slug}")

      assert redirected_to(conn, 302) == destination_url
    end

    test "redirects to the root path if the link is not found", %{conn: conn} do
      conn = get(conn, "/not-a-link")

      assert redirected_to(conn) == "/"
    end

    test "increments the link's visit count", %{conn: conn} do
      link = link_fixture()
      get(conn, "/#{link.slug}")

      assert LinkEngine.get_link!(link.id).visits == 1

      get(conn, "/#{link.slug}")

      assert LinkEngine.get_link!(link.id).visits == 2
    end
  end
end

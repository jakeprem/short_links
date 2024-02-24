defmodule ShortLinksWeb.RedirectControllerTest do
  use ShortLinksWeb.ConnCase

  import ShortLinks.LinkEngineFixtures, only: [link_fixture: 1]

  describe "execute link" do
    test "redirects to the link's destination" do
      link = link_fixture(%{destination: "https://elixir-lang.org"})
      conn = get(build_conn(), "/#{link.slug}")

      assert redirected_to(conn, 302) == link.destination
    end

    test "redirects to the root path if the link is not found" do
      conn = get(build_conn(), "/not-a-link")

      assert redirected_to(conn) == "/"
    end
  end
end

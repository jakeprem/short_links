defmodule ShortLinks.LinkEngineTest do
  use ShortLinks.DataCase, async: false

  alias ShortLinks.LinkEngine

  import ShortLinks.LinkEngineFixtures, only: [link_fixture: 0]

  describe "generate_slug/0" do
    test "generates a random 8 character slug" do
      assert String.match?(LinkEngine.generate_slug(), ~r/^[a-z1-9]{8}$/)
    end
  end

  describe "create_link/1" do
    test "creates a new link for the given destination" do
      {:ok, link} =
        LinkEngine.create_link(%{destination: "https://example.com", slug: "abcd1234"})

      assert link.destination == "https://example.com"
      assert link.slug == "abcd1234"
    end

    test "returns an error if the destination is missing or malformed" do
      {:error, changeset} = LinkEngine.create_link(%{destination: "missing-or-malformed"})
      assert changeset.errors[:destination] == {"invalid URL, no scheme given", []}

      {:error, _changeset} = LinkEngine.create_link(%{})
    end

    test "returns an error if the slug is already taken" do
      {:ok, _link} =
        LinkEngine.create_link(%{destination: "https://example.com", slug: "WoofWoof"})

      {:error, changeset} =
        LinkEngine.create_link(%{destination: "https://example.com", slug: "WoofWoof"})

      assert {"has already been taken", [{:constraint, :unique} | _]} = changeset.errors[:slug]
    end
  end

  describe "change_link/2" do
    test "changes the link with the given attributes" do
      link = link_fixture()
      changeset = LinkEngine.change_link(link, %{destination: "https://new-url.com"})

      assert changeset.valid?
      assert changeset.changes.destination == "https://new-url.com"
    end

    test "changes the link with invalid attributes" do
      link = link_fixture()
      changeset = LinkEngine.change_link(link, %{destination: "missing-or-malformed"})

      assert changeset.errors[:destination] == {"invalid URL, no scheme given", []}
    end
  end

  describe "get_link/1" do
    test "returns the link with the given id" do
      link = link_fixture()

      assert link == LinkEngine.get_link(link.id)
    end

    test "returns nil if the link does not exist" do
      assert nil == LinkEngine.get_link(0)
    end
  end

  describe "list_links/0" do
    test "returns all links" do
      link1 = link_fixture()
      link2 = link_fixture()
      link3 = link_fixture()

      assert [link1, link2, link3] == LinkEngine.list_links()
    end
  end
end

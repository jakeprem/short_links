defmodule ShortLinks.LinkEngineTest do
  use ShortLinks.DataCase, async: false

  alias ShortLinks.LinkEngine

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
end

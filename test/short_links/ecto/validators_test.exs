defmodule ShortLinks.Ecto.ValidatorsTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias ShortLinks.Ecto.Validators

  # This seems like it could be a good place for property based testing.
  # This could also be cleaned up with some helper functions but sometimes
  # those end up making the tests really hard to parse and/or update

  # This probably doesn't comprehensively cover everything in
  # the URL RFC (https://datatracker.ietf.org/doc/html/rfc1738),
  # but it should cover most common cases. Copilot helped generate the combos here
  describe "validate_url/2" do
    defp url_changeset(url) do
      {%{}, %{url_field: :string}}
      |> Changeset.cast(%{url_field: url}, [:url_field])
      |> Validators.validate_url(:url_field)
    end

    test "validates normal https URLs" do
      valid_urls = [
        "https://example.com",
        "https://example.com/",
        "https://example.com/path",
        "https://example.com/path/",
        "https://example.com/path/to",
        "https://example.com/path/to/",
        "https://example.com/path/to?query=string",
        "https://example.com/path/to/?query=string",
        "https://example.com/path/to?query=string#fragment",
        "https://example.com/path/to/?query=string#fragment"
      ]

      for url <- valid_urls do
        changeset = url_changeset(url)
        assert changeset.valid?
      end
    end

    test "validates a normal http URLs" do
      valid_urls = [
        "http://example.com",
        "http://example.com/",
        "http://example.com/path",
        "http://example.com/path/",
        "http://example.com/path/to",
        "http://example.com/path/to/",
        "http://example.com/path/to?query=string",
        "http://example.com/path/to/?query=string",
        "http://example.com/path/to?query=string#fragment",
        "http://example.com/path/to/?query=string#fragment"
      ]

      for url <- valid_urls do
        changeset = url_changeset(url)
        assert changeset.valid?
      end
    end

    test "rejects non http/https URLs" do
      invalid_urls = [
        "ftp://example.com",
        "sketchycrypto://example.com",
        "mailto://example.com"
      ]

      for url <- invalid_urls do
        changeset = url_changeset(url)
        refute changeset.valid?

        assert changeset.errors[:url_field] ==
                 {"invalid URL, only HTTP and HTTPS are supported", []}
      end
    end

    test "rejects URLs with a domain but without a scheme" do
      invalid_urls = [
        "example.com",
        "example.com/path?query=string#fragment"
      ]

      for url <- invalid_urls do
        changeset = url_changeset(url)
        refute changeset.valid?
        assert changeset.errors[:url_field] == {"invalid URL, no scheme given", []}
      end
    end

    test "rejects URLs without a domain" do
      invalid_urls = [
        "https://",
        "https:///",
        "https://?query=string",
        "https:///?query=string",
        "https://#fragment",
        "https:///#fragment",
        "http://",
        # Elixir's URI parses domain:port as a scheme if no scheme is given, therefore
        # this will be treated as having no domain
        "localhost:8080"
      ]

      for url <- invalid_urls do
        changeset = url_changeset(url)
        refute changeset.valid?
        assert changeset.errors[:url_field] == {"invalid URL, no host given", []}
      end
    end

    test "rejects URLs with only paths" do
      invalid_urls = [
        "/path",
        # Elixir's URI parses a bare domain like this as a path
        "http",
        "https"
      ]

      for url <- invalid_urls do
        changeset = url_changeset(url)
        refute changeset.valid?
        assert changeset.errors[:url_field] == {"invalid URL, no scheme given", []}
      end
    end

    test "rejects weird URLs" do
      invalid_urls = [
        "schemas_cant_have_underscores://hello.com",
        "https://☢️☢️☢️.com"
      ]

      for url <- invalid_urls do
        changeset = url_changeset(url)
        refute changeset.valid?
        assert changeset.errors[:url_field] == {"invalid URL", []}
      end
    end
  end
end

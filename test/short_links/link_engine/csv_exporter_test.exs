defmodule ShortLinks.LinkEngine.CSVExporterTest do
  use ShortLinks.DataCase, async: false

  alias ShortLinks.LinkEngine.CSVExporter

  import ShortLinks.LinkEngineFixtures, only: [link_fixture: 1]

  describe "get_links_csv_stream" do
    test "returns a CSV stream of links" do
      links = Enum.map(1..3, &link_fixture(%{destination: "https://jakeprem.com", visits: &1}))
      link_csv_stream = CSVExporter.get_links_csv_stream(links)

      csv_rows = Enum.map(link_csv_stream, &IO.iodata_to_binary/1)

      link_binaries =
        Enum.map(links, fn link ->
          Enum.join([link.slug, link.destination, link.visits, link.inserted_at], "\t") <> "\n"
        end)

      assert csv_rows == ["Slug\tDestination\tVisits\tCreated At\n" | link_binaries]
    end

    test "returns a CSV stream of links with full slug urls" do
      links = Enum.map(1..3, &link_fixture(%{destination: "https://jakeprem.com", visits: &1}))

      test_url = "https://links.short/"

      link_csv_stream = CSVExporter.get_links_csv_stream(links, test_url)

      csv_rows = Enum.map(link_csv_stream, &IO.iodata_to_binary/1)

      link_binaries =
        Enum.map(links, fn link ->
          Enum.join(
            ["#{test_url}#{link.slug}", link.destination, link.visits, link.inserted_at],
            "\t"
          ) <> "\n"
        end)

      assert csv_rows == ["Slug\tDestination\tVisits\tCreated At\n" | link_binaries]
    end
  end
end

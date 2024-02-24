defmodule ShortLinks.LinkEngine.CSVExporter do
  @moduledoc """
  Contains functions for exporting links to CSV.
  """
  NimbleCSV.define(__MODULE__.LinkParser, separator: "\t", escape: "\"")

  # Running the headers through link_to_row/2 makes it easier to change the order
  @header %{
    slug: "Slug",
    destination: "Destination",
    visits: "Visits",
    inserted_at: "Created At"
  }
  @doc """
  Returns a stream that will produce a CSV from the given links.

  Takes an enumerable of links and optional URL (used to expand the short links in the CSV)
  """
  def get_links_csv_stream(links, url \\ nil) do
    [@header]
    |> Stream.concat(links)
    |> Stream.map(&link_to_row(&1, url))
    |> __MODULE__.LinkParser.dump_to_stream()
  end

  @doc false
  # This is really just here for testing,
  # so @doc false will make it less accessible
  def parse_links_csv(csv) do
    __MODULE__.LinkParser.parse_string(csv)
  end

  defp link_to_row(link, url) do
    # This bit of coupling isn't the greatest. It would be better to have a single
    # source of trueh for generating slug URLs.
    slug = if is_nil(url) or link.slug == "Slug", do: link.slug, else: "#{url}#{link.slug}"

    [
      slug,
      link.destination,
      link.visits,
      link.inserted_at
    ]
  end
end

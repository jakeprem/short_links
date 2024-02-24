defmodule ShortLinks.LinkEngineFixtures do
  @moduledoc """
  Generate entities via the LinkEngine for use in tests.
  """
  alias ShortLinks.LinkEngine

  @doc """
  Generate a link.
  """
  def link_fixture(attrs \\ %{}) do
    {:ok, link} =
      attrs
      |> Enum.into(%{
        destination: "https://example.com",
        slug: LinkEngine.generate_slug(),
        visits: 0
      })
      |> LinkEngine.create_link()

    link
  end
end

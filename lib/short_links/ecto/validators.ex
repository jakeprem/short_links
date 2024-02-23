defmodule ShortLinks.Ecto.Validators do
  @moduledoc """
  A module for custom changeset validators
  """

  # It would be fine to import all of Ecto.Query too really
  import Ecto.Changeset, only: [validate_change: 3]
  import ShortLinks.Utils, only: [is_blank: 1]

  @doc """
  Validates that a change is a valid URL.

  Only accepts URLs with HTTP or HTTPS explicitly included.
  """
  def validate_url(changeset, field) do
    validate_change(changeset, field, fn ^field, change ->
      with {:ok, uri} <- URI.new(change) do
        case uri do
          %URI{scheme: nil} -> [{field, "invalid URL, no scheme given"}]
          %URI{host: host} when is_blank(host) -> [{field, "invalid URL, no host given"}]
          %URI{scheme: scheme} when scheme in ~w(http https) -> []
          _ -> [{field, "invalid URL, only HTTP and HTTPS are supported"}]
        end
      else
        _ -> [{field, "invalid URL"}]
      end
    end)
  end
end

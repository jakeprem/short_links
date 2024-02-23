defmodule ShortLinks.Utils do
  @moduledoc """
  A place for all those simple utility functions and guards.
  """

  @doc """
  A guard that checks if a value is `nil` or `""`.

  ## Examples

  iex> is_blank(nil)
  true

  iex> is_blank("")
  true

  iex> is_blank(" ")
  false
  """
  defguard is_blank(value) when value in [nil, ""]

  @doc """
  A guard that checks if a value is not `nil` or `""`.

  ## Examples

  iex> not_blank(nil)
  false

  iex> not_blank("")
  false

  iex> not_blank(" ")
  true
  """
  defguard not_blank(value) when not is_blank(value)
end

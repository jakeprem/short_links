defmodule ShortLinksWeb.LinkHTML do
  use ShortLinksWeb, :html

  embed_templates "link_html/*"

  @doc """
  Renders a link form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def link_form(assigns)

  @doc """
  Renders a link for the given slug.
  """
  attr :conn, Plug.Conn, required: true
  attr :slug, :string, required: true

  slot :inner_block, required: false

  def link_for_slug(assigns) do
    ~H"""
    <.link href={url_for_slug(assigns.conn, assigns.slug)}>
      <%= if @inner_block == [] do %>
        <%= url_for_slug(assigns.conn, assigns.slug) %>
      <% else %>
        <%= render_slot(@inner_block) %>
      <% end %>
    </.link>
    """
  end

  def url_for_slug(conn, slug) do
    unverified_url(conn, "/#{slug}")
  end
end

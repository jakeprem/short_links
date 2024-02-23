defmodule ShortLinks.Repo do
  use Ecto.Repo,
    otp_app: :short_links,
    adapter: Ecto.Adapters.SQLite3
end

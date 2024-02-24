# The code quality in this module is subpar. It really should be refactored,
# and probably define a module is just defined in this file.
# This is my first time using Benchee and I ended up having to
# iterate quite a bit to get cookies and CSRF working with Req
#
# It works well enough but it is very messy.

url = System.get_env("API_URL", "http://localhost:4000")
alias ShortLinks.LinkEngine
require Logger

# Mainly avoids Req debug logs.
# May give a small performance bump
Logger.configure(level: :info)

link_slugs =
  Enum.map(1..100, fn _ ->
    LinkEngine.create_link(%{
      slug: LinkEngine.generate_slug(),
      destination: "https://elixir-lang.org"
    })
    |> elem(1)
    |> Map.get(:slug)
  end)

extract_cookie = fn resp ->
  resp.headers["set-cookie"]
end

extract_csrf_token = fn resp ->
  resp.body
  |> Floki.parse_document!()
  |> Floki.find("input[name=_csrf_token]")
  |> Floki.attribute("value")
  |> List.first()
end

fetch_csrf_w_cookie = fn cookie ->
  Req.get!("#{url}/", headers: %{"cookie" => cookie})
  |> extract_csrf_token.()
end

init_resp = Req.get!("#{url}/")

cookie = extract_cookie.(init_resp)

create_link = fn ->
  csrf_token = fetch_csrf_w_cookie.(cookie)

  Req.post("#{url}/",
    form: ["link[destination]": "https://jakeprem.com"],
    headers: %{"x-csrf-token" => csrf_token, "cookie" => cookie}
  )
end

execute_link = fn ->
  # To make sure we don't hit the same link which might be cached
  slug = Enum.random(link_slugs)

  Req.get("#{url}/#{slug}", redirect: false)
end

short_slugs = link_slugs |> Enum.shuffle() |> Enum.take(5)

execute_contentious_links = fn ->
  slug = Enum.random(short_slugs)

  Req.get("#{url}/#{slug}", redirect: false)
end

parallel =
  case System.argv() do
    [] -> 10
    [arg] -> String.to_integer(arg)
  end

Benchee.run(
  %{
    "create link (post /)" => create_link,
    "execute short link (/:slug)" => execute_link,
    "execute contentious (/:slug)" => execute_contentious_links,
    "mixed use" => fn ->
      Enum.random([create_link, execute_link, execute_link, execute_link, execute_link]).()
    end
  },
  parallel: parallel
)

# ShortLinks

## Running
To start the ShortLinks Phoenix Server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

- [New Link (`GET https://localhost:4000/`)](http://localhost:4000)
- [Stats (`GET https://localhost:4000/stats`)}](http://localhost:4000/stats)

### Benchmarking
I have some benchmarking code setup using Benchee. I recommend running the benchmarks using `MIX_ENV=benchmark` both for performance reasons and to avoid spamming your dev database.

- `MIX_ENV=benchmark mix setup`
- `MIX_ENV=benchmark mix phx.server`
- Then in a separate terminal `mix run benchmark.exs`
  - You can also run `mix run benchmark.exs -- 10` to change the parallel count for Benchee.
  - The benchmark itself runs in dev right now. Just for less changes to dependencies and where they run.
  - Eventually an alias should be made for this`mix benchmark`
  - Likewise, `mix bechmark.server`, etc would be nice but needs some environment setup to make the command run in the right environment.


## Benchmarks
My benchmarks are far from scientific. Thus far I've been running the bunchmarks on the same machine as the server. I also have added overhead parsing out the CSRF token with Floki which probably hurts speeds slightly on the create test.

Based on my benchmarking, this solution meets the required performance characterstics up to 500 parallel connections on my machine (M1 Macbook Pro, 16gb of RAM). 

I suspect that the higher parallel count benchmarks are stealing more CPU time from the server resulting in the slower speeds. I'd need to benchmark across two machines to verify, which also means I'd need to update the benchmark config to listen on a locally addressable interface (i.e. not just 127.0.0.1)

| Name      | Description |
| ----------- | ----------- |
| execute contentious      | Tests the redirect on a smaller number of links (10). Trying to test performance when visits (and the corresponding writes) are focused on a few links. |
| execute short link | Picks a random slug out of a list of 100 that are preinserted, and hits the redirect endpoint for it (`/:slug`) |
| mixed use | Mixes redirect execution and create. Trying to see if the visit count slows creation or vice versa |
| create link | Tests the speed of creating links. Does a GET to the new/form page first to get a CSRF token, then a POST to create a link. |

### parallel=1
```
Name                                   ips        average  deviation         median         99th %
execute contentious (/:slug)        5.40 K      185.05 μs    ±20.15%      177.42 μs      344.81 μs
execute short link (/:slug)         5.18 K      193.15 μs    ±21.27%      184.13 μs      358.06 μs
mixed use                           1.77 K      563.89 μs   ±109.01%      265.19 μs     2523.68 μs
create link (post /)                0.30 K     3342.23 μs    ±40.04%     3081.17 μs     7454.18 μs
```

### parallel=100
```
Name                                   ips        average  deviation         median         99th %
execute contentious (/:slug)        161.51        6.19 ms    ±25.14%        5.96 ms       13.66 ms
execute short link (/:slug)         158.16        6.32 ms    ±19.94%        6.12 ms       12.47 ms
mixed use                            97.48       10.26 ms    ±60.89%        7.49 ms       30.47 ms
create link (post /)                 33.87       29.53 ms    ±24.51%       27.17 ms       58.26 ms
```
### parallel=500
```
Name                                   ips        average  deviation         median         99th %
execute contentious (/:slug)         34.14       29.29 ms    ±14.15%       28.18 ms       47.52 ms
execute short link (/:slug)          30.12       33.20 ms    ±25.73%       30.86 ms       75.27 ms
mixed use                            16.16       61.89 ms    ±58.98%       45.59 ms      165.74 ms
create link (post /)                  6.83      146.33 ms     ±9.92%      141.32 ms      195.00 ms
```

## Decicions

### Slugs
Right now I'm generating these in the controller via a function on the context. It doesn't feel great, but the flexibility is nice for testing the unique constraints and other slug-related tests.

Doing a `Map.put(params, "slug", generate_slug())` in the controller so it should still keep users
from submitting their own. I'm using Nanoid to generate the slugs, no particular reason other than
it's fairly easy to use.

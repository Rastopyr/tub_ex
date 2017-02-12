# TubEx

[![Build Status](https://travis-ci.org/Rastopyr/tub_ex.svg?branch=master)](https://travis-ci.org/Rastopyr/tub_ex)
[![Coverage Status](https://coveralls.io/repos/github/Rastopyr/tub_ex/badge.svg?branch=master)](https://coveralls.io/github/Rastopyr/tub_ex?branch=master)

Lightweight YouTube v3 API Wrapper

[Documentation](https://hexdocs.pm/tub_ex)

## Note

Fork of https://github.com/yoavlt/tubex.

#### Motivation


Actually, `tubex` not support of @yoavlt about 11 months.
But package is uses and downloaded each day. Maintainer of master
package not approve any pull requests and updates.

So, for future support of YouTube functionality in elixir flow,
i decided to fork `tubex` package.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add tub_ex to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:tub_ex, "~> 0.0.11"}]
end
```

2. Ensure tub_ex is started before your application:

```elixir
def application do
  [applications: [:tub_ex]]
end
```

  3. Put your config YouTube Data API Key

```elixir
config :tub_ex, TubEx,
  api_key: "< Your API Key >"
```

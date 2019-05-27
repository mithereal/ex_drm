# Drm

**About: Drm License server responsible for generating/verify/sync licenses with upstream server**

##### Currently we can only generate/validate/store keys, remote license functions ie: validation types (concurrent users check, over license limit, sync, etc) are not working currently

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `drm` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:drm, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/license](https://hexdocs.pm/license).


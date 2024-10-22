# StacValidator

A library for validating SpatioTemporal Asset Catalog (STAC) metadata.

## Installation

The package can be installed by adding `stac_validator` to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [
    {:stac_validator, "~> 0.1.1"}
  ]
end
```

## Usage

```elixir
item = %{
  "type" => "Feature",
  "stac_version" => "1.0.0",
  "id" => "example-item",
  "geometry" => nil,
  "properties" => %{
    "datetime" => "2024-01-01T00:00:00Z"
  },
  "links" => [],
  "assets" => %{}
}

case StacValidator.validate(item) do
  {:ok, true} -> IO.puts("Valid STAC item!")
  {:error, reason} -> IO.puts("Invalid STAC object: #{reason}")
end
```

## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](./LICENSE) file for details.

The documentation can be found at [https://hexdocs.pm/stac_validator](https://hexdocs.pm/stac_validator)

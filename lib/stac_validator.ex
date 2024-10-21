defmodule StacValidator do
  @moduledoc """
  StacValidator provides functions for validating Spatio-Temporal Asset Catalog (STAC) metadata against the STAC specification.
  """

  require Logger

  @stac_version "1.1.0"
  @stac_schema_url "https://schemas.stacspec.org/v"

  @doc """
  Validates a STAC item, collection, or catalog against the STAC specification.

  ## Examples

  ### Validating a STAC Item:

      iex> StacValidator.validate(%{
      ...>   "type" => "Feature",
      ...>   "stac_version" => "1.0.0",
      ...>   "id" => "example-item",
      ...>   "geometry" => nil,
      ...>   "properties" => %{
      ...>     "datetime" => "2024-01-01T00:00:00Z"
      ...>   },
      ...>   "links" => [],
      ...>   "assets" => %{}
      ...> })
      {:ok, true}

  ### Validating a STAC Collection:

      iex> StacValidator.validate(%{
      ...>   "type" => "Collection",
      ...>   "stac_version" => "1.0.0",
      ...>   "id" => "example-collection",
      ...>   "description" => "A collection of STAC items",
      ...>   "license" => "other",
      ...>   "extent" => %{
      ...>     "spatial" => %{
      ...>       "bbox" => [[-180.0, -90.0, 180.0, 90.0]]
      ...>     },
      ...>     "temporal" => %{
      ...>       "interval" => [["2020-01-01T00:00:00Z", nil]]
      ...>     }
      ...>   },
      ...>   "links" => []
      ...> })
      {:ok, true}

  ### Validating a STAC Catalog:

      iex> StacValidator.validate(%{
      ...>   "type" => "Catalog",
      ...>   "stac_version" => "1.0.0",
      ...>   "id" => "example-catalog",
      ...>   "description" => "A catalog of STAC collections and items",
      ...>   "links" => [
      ...>     %{
      ...>       "rel" => "child",
      ...>       "href" => "collection.json",
      ...>       "type" => "application/json"
      ...>     }
      ...>   ]
      ...> })
      {:ok, true}

  """
  @spec validate(map()) :: {:ok, boolean()} | {:error, String.t()}
  def validate(item, opts \\ [])

  def validate(%{"type" => "Feature"} = item, opts) do
    version = item["stac_version"] || opts[:stac_version] || @stac_version

    with {:ok, schema} <- load_schema("item", version),
         :ok <- validate_required_fields(item),
         :ok <- validate_against_schema(item, schema),
         :ok <- validate_extensions(item, opts[:extensions] || []),
         :ok <- validate_business_rules(item) do
      {:ok, true}
    else
      {:error, reason} -> {:error, "Invalid STAC Item: #{reason}"}
    end
  end

  def validate(%{"type" => "Collection"} = collection, opts) do
    version = collection["stac_version"] || opts[:stac_version] || @stac_version

    with {:ok, schema} <- load_schema("collection", version),
         :ok <- validate_required_fields(collection),
         :ok <- validate_against_schema(collection, schema),
         :ok <- validate_extensions(collection, opts[:extensions] || []),
         :ok <- validate_business_rules(collection) do
      {:ok, true}
    else
      {:error, reason} -> {:error, "Invalid STAC Collection: #{reason}"}
    end
  end

  def validate(%{"type" => "Catalog"} = catalog, opts) do
    version = catalog["stac_version"] || opts[:stac_version] || @stac_version

    with {:ok, schema} <- load_schema("catalog", version),
         :ok <- validate_required_fields(catalog),
         :ok <- validate_against_schema(catalog, schema),
         :ok <- validate_business_rules(catalog) do
      {:ok, true}
    else
      {:error, reason} -> {:error, "Invalid STAC Catalog: #{reason}"}
    end
  end

  def validate(%{"type" => type}, _opts) when type not in ["Feature", "Collection", "Catalog"] do
    {:error,
     "Invalid STAC object: unknown type '#{type}'. Expected one of: Feature, Collection, or Catalog"}
  end

  def validate(%{} = _item, _opts) do
    {:error, "Invalid STAC object: missing required fields [type]"}
  end

  def validate(invalid, _opts) do
    {:error, "Invalid STAC object: expected map, got #{inspect(invalid)}"}
  end

  # Private functions

  # NOTE: Item bbox, geometry, and collection have conditional rules
  @required_item_fields ~w(type stac_version id properties links assets)
  @required_collection_fields ~w(type stac_version id description license extent links)
  @required_catalog_fields ~w(type stac_version id description links)

  defp validate_required_fields(%{"type" => "Feature"} = item),
    do: list_missing_fields(item, @required_item_fields)

  defp validate_required_fields(%{"type" => "Collection"} = item),
    do: list_missing_fields(item, @required_collection_fields)

  defp validate_required_fields(%{"type" => "Catalog"} = item),
    do: list_missing_fields(item, @required_catalog_fields)

  defp list_missing_fields(object, fields) do
    case MapSet.subset?(MapSet.new(fields), MapSet.new(Map.keys(object))) do
      true ->
        :ok

      false ->
        missing_fields =
          MapSet.difference(MapSet.new(fields), MapSet.new(Map.keys(object)))

        {:error,
         "missing required fields [" <> Enum.join(MapSet.to_list(missing_fields), ", ") <> "]"}
    end
  end

  defp load_schema(schema_type, schema_version, opts \\ []) do
    case Keyword.get(opts, :schema_source, :remote) do
      :local -> load_local_schema(schema_type, schema_version)
      :remote -> load_remote_schema(schema_type, schema_version)
    end
  end

  defp load_remote_schema(schema_type, version) do
    case HTTPoison.get(stac_schema_url(schema_type, version)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, _} ->
        {:error,
         "Could not locate schema for the STAC type and version combination, #{schema_type} v#{version}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp stac_schema_url(type, version) do
    @stac_schema_url <> version <> "/#{type}-spec/json-schema/#{type}.json"
  end

  defp load_local_schema(schema_type, version) do
    schema_path =
      Path.join([
        :code.priv_dir(:stac_validator),
        "schemas",
        "v#{version}",
        "#{schema_type}-spec",
        "#{schema_type}.json"
      ])

    case File.read(schema_path) do
      {:ok, schema_json} -> Jason.decode(schema_json)
      {:error, _} -> {:error, "schema file not found: #{schema_path}"}
    end
  end

  defp validate_against_schema(object, schema) do
    case ExJsonSchema.Validator.validate(schema, object) do
      :ok -> :ok
      {:error, errors} -> {:error, format_validation_errors(errors)}
    end
  end

  defp validate_extensions(_item, []), do: :ok

  defp validate_extensions(_item, _extensions), do: :ok

  defp validate_business_rules(%{"type" => "Feature"} = item) do
    with :ok <- validate_datetime(item),
         :ok <- validate_links(item) do
      validate_assets(item)
    end
  end

  defp validate_business_rules(%{"type" => "Collection"} = collection) do
    with :ok <- validate_links(collection) do
      validate_assets(collection)
    end
  end

  defp validate_business_rules(%{"type" => "Catalog"} = catalog) do
    validate_links(catalog)
  end

  defp validate_datetime(%{"properties" => %{"datetime" => datetime}}) do
    case DateTime.from_iso8601(datetime) do
      {:ok, _datetime, _offset} -> :ok
      {:error, _} -> {:error, "invalid datetime format"}
    end
  end

  defp validate_datetime(_), do: {:error, "missing datetime in properties"}

  defp validate_links(%{"links" => links}) when is_list(links), do: :ok
  defp validate_links(_), do: {:error, "invalid links format"}

  defp validate_assets(%{"assets" => assets}) when is_map(assets), do: :ok
  defp validate_assets(_), do: :ok

  defp format_validation_errors(errors) when is_list(errors) do
    Enum.map_join(errors, "; ", &format_validation_error/1)
  end

  defp format_validation_error({path, error}) do
    "#{path}: #{error}"
  end
end

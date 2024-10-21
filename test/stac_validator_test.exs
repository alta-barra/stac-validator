defmodule StacValidatorTest do
  use ExUnit.Case
  doctest StacValidator

  import StacValidator.StacFixtures

  describe "validate/2 for items" do
    setup do
      valid_item = valid_item()
      {:ok, valid_item: valid_item}
    end

    test "validates a valid STAC item", %{valid_item: item} do
      assert {:ok, true} = StacValidator.validate(item)
    end

    test "fails on missing required fields", %{valid_item: item} do
      invalid_items = [
        %{},
        %{"type" => "Feature"},
        %{"type" => "Feature", "stac_version" => "1.0.0"},
        Map.drop(item, ["geometry"])
      ]

      for invalid_item <- invalid_items do
        {:error, reason} = StacValidator.validate(invalid_item)

        assert String.match?(
                 reason,
                 ~r/Invalid STAC \w+: (missing required|Expected all of the schemata to match)/
               )
      end
    end

    test "validates item type", %{valid_item: item} do
      invalid_item = %{item | "type" => "NotFeature"}
      assert {:error, _} = StacValidator.validate(invalid_item)
    end

    test "validates stac version format", %{valid_item: item} do
      invalid_versions = [
        %{item | "stac_version" => "invalid"},
        %{item | "stac_version" => "1"},
        %{item | "stac_version" => "1.0"},
        %{item | "stac_version" => "v1.0.0"}
      ]

      for invalid_item <- invalid_versions do
        assert {:error, _} = StacValidator.validate(invalid_item)
      end
    end

    test "validates geometry", %{valid_item: item} do
      invalid_geometries = [
        %{item | "geometry" => "not an object"},
        %{item | "geometry" => %{"type" => "Unknown"}},
        # Missing coordinates
        %{item | "geometry" => %{"type" => "Point"}},
        %{
          item
          | "geometry" => %{
              "type" => "Point",
              "coordinates" => "not an array"
            }
        },
        %{
          item
          | "geometry" => %{
              "type" => "Point",
              # Incomplete coordinates
              "coordinates" => [0]
            }
        }
      ]

      for invalid_item <- invalid_geometries do
        assert {:error, _} = StacValidator.validate(invalid_item)
      end
    end

    test "validates datetime in properties", %{valid_item: item} do
      invalid_datetimes = [
        put_in(item, ["properties", "datetime"], "not a date"),
        # Invalid month
        put_in(item, ["properties", "datetime"], "2024-13-01T00:00:00Z"),
        # Invalid day
        put_in(item, ["properties", "datetime"], "2024-01-32T00:00:00Z"),
        # Missing timezone
        put_in(item, ["properties", "datetime"], "2024-01-01 00:00:00")
      ]

      for invalid_item <- invalid_datetimes do
        assert {:error, _} = StacValidator.validate(invalid_item)
      end
    end

    test "validates links structure", %{valid_item: item} do
      invalid_links = [
        %{item | "links" => "not an array"},
        %{
          item
          | "links" => [
              "not an object"
            ]
        },
        %{
          item
          | "links" => [
              # Missing rel
              %{"href" => "https://example.com"}
            ]
        },
        %{
          item
          | "links" => [
              # Missing href
              %{"rel" => "self"}
            ]
        }
      ]

      for invalid_item <- invalid_links do
        assert {:error, _} = StacValidator.validate(invalid_item)
      end
    end

    test "validates assets structure", %{valid_item: item} do
      invalid_assets = [
        %{item | "assets" => "not an object"},
        %{
          item
          | "assets" => %{
              "visual" => "not an object"
            }
        },
        %{
          item
          | "assets" => %{
              # Missing href
              "visual" => %{}
            }
        },
        %{
          item
          | "assets" => %{
              "visual" => %{
                # href should be string
                "href" => 123
              }
            }
        }
      ]

      for invalid_item <- invalid_assets do
        assert {:error, _} = StacValidator.validate(invalid_item)
      end
    end

    test "validates with extensions", %{valid_item: item} do
      # Example with EO extension
      eo_item = add_stac_extension(item, "eo")

      assert {:ok, true} = StacValidator.validate(eo_item, extensions: ["eo"])

      # Invalid EO extension data
      invalid_eo_item =
        put_in(item, ["stac_extensions"], ["eo"])
        |> put_in(["properties", "eo:bands"], [
          # Missing required fields
          %{"name" => "B1"}
        ])

      assert {:error, _} = StacValidator.validate(invalid_eo_item, extensions: ["eo"])
    end

    test "handles different STAC versions", %{valid_item: item} do
      # Test with explicit version option
      assert {:ok, true} = StacValidator.validate(item, version: "1.1.0")

      # Different version should still work if schema exists
      v0_9_item = %{item | "stac_version" => "1.0.0-beta.2"}
      assert {:ok, true} = StacValidator.validate(v0_9_item, version: "1.0.0-beta.2")
    end

    test "handles both local and remote schemas", %{valid_item: item} do
      # Should work with local schemas (default)
      assert {:ok, true} = StacValidator.validate(item)

      # Should work with remote schemas when configured
      original_source = Application.get_env(:stac_validator, :schema_source)
      Application.put_env(:stac_validator, :schema_source, :remote)

      assert {:ok, true} = StacValidator.validate(item)

      # Reset config
      Application.put_env(:stac_validator, :schema_source, original_source)
    end
  end

  describe "validate/2 for collections" do
    setup do
      valid_collection = valid_collection()
      {:ok, valid_collection: valid_collection}
    end

    test "validates a valid STAC collection", %{valid_collection: collection} do
      assert {:ok, true} = StacValidator.validate(collection)
    end

    test "fails on missing required fields" do
      invalid_collections = [
        %{},
        %{"type" => "Collection"},
        %{"type" => "Collection", "stac_version" => "1.0.0"}
      ]

      for invalid_collection <- invalid_collections do
        {:error, reason} = StacValidator.validate(invalid_collection)
        assert String.match?(reason, ~r/Invalid STAC \w+: missing required/)
      end
    end

    test "validates collection type", %{valid_collection: collection} do
      invalid_collection = %{collection | "type" => "NotFeature"}
      assert {:error, _} = StacValidator.validate(invalid_collection)
    end

    test "validates stac version format", %{valid_collection: collection} do
      invalid_versions = [
        %{collection | "stac_version" => "invalid"},
        %{collection | "stac_version" => "1"},
        %{collection | "stac_version" => "1.0"},
        %{collection | "stac_version" => "v1.0.0"}
      ]

      for invalid_collection <- invalid_versions do
        assert {:error, _} = StacValidator.validate(invalid_collection)
      end
    end
  end
end

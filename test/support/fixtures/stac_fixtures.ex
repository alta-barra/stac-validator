defmodule StacValidator.StacFixtures do
  @moduledoc """
  This module defines test helpers for creating STAC Items.
  """

  def valid_item do
    %{
      "assets" => %{
        "http://esipfed.org/ns/fedsearch/1.1/data#" => %{
          "href" => "https://search.earthdata.nasa.gov/search/granules?p=C3246712936-LARC_CLOUD"
        },
        "http://esipfed.org/ns/fedsearch/1.1/documentation#" => %{
          "href" => "https://asdc.larc.nasa.gov/documents/prefire/PREFIRE_L1-L2-L3-ATBD.pdf"
        },
        "http://esipfed.org/ns/fedsearch/1.1/metadata#" => %{
          "href" => "https://doi.org/10.5067/PREFIRE-SAT2/PREFIRE/PAYLOAD-TLM_L0.R01"
        },
        "http://esipfed.org/ns/fedsearch/1.1/s3#" => %{
          "href" =>
            "s3://asdc-prod-protected/PREFIRE/PREFIRE_SAT2_0-PAYLOAD-TLM_R01/2024.06.03/prefire_02_payload_tlm_20240603202505_20240603210259_20240919222234.bin",
          "title" => "This link provides direct download access via S3 to the granule"
        }
      },
      "geometry" => %{
        "type" => "Polygon",
        "coordinates" => [
          [
            [-180, 84],
            [180, 84],
            [180, -84],
            [-180, -84],
            [-180, 84]
          ]
        ]
      },
      "bbox" => [
        -180,
        -84,
        180,
        84
      ],
      "collection" => "PREFIRE_SAT2_0-PAYLOAD-TLM",
      "id" => "prefire_02_payload_tlm_20240603202505_20240603210259_20240919222234.bin",
      "links" => [
        %{
          "href" =>
            "https://alta-barra.com/api/stac/collections/PREFIRE_SAT2_0-PAYLOAD-TLM/items/prefire_02_payload_tlm_20240603202505_20240603210259_20240919222234.bin",
          "rel" => "self"
        },
        %{
          "href" => "https://alta-barra.com/api/stac/collections/PREFIRE_SAT2_0-PAYLOAD-TLM",
          "rel" => "parent"
        },
        %{
          "href" => "https://alta-barra.com/api/stac/collections/PREFIRE_SAT2_0-PAYLOAD-TLM",
          "rel" => "collection"
        },
        %{
          "href" => "https://cmr.earthdata.nasa.gov/search/concepts/G3249449623-LARC_CLOUD.json",
          "rel" => "via",
          "title" => "CMR JSON",
          "type" => "application/json"
        },
        %{
          "href" => "https://cmr.earthdata.nasa.gov/search/concepts/G3249449623-LARC_CLOUD.xml",
          "rel" => "via",
          "title" => "CMR ECHO10",
          "type" => "application/xml"
        },
        %{
          "href" =>
            "https://cmr.earthdata.nasa.gov/search/concepts/G3249449623-LARC_CLOUD.umm_json",
          "rel" => "via",
          "title" => "CMR UMM-G",
          "type" => "application/vnd.nasa.cmr.umm+json"
        }
      ],
      "properties" => %{
        "datetime" => "2024-06-03T20:25:05.000Z",
        "end_datetime" => "2024-06-03T21:02:59.000Z",
        "start_datetime" => "2024-06-03T20:25:05.000Z"
      },
      "type" => "Feature",
      "stac_version" => "1.1.0"
    }
  end

  def add_stac_extension(item, "eo", opts \\ []) do
    item
    |> put_in(["stac_extensions"], ["https://stac-extensions.github.io/eo/v2.0.0/schema.json"])
    |> put_in(["properties", "eo:bands"], [
      %{
        "name" => "B1",
        "eo:common_name" => "blue",
        "eo:center_wavelength" => 0.47
      }
    ])
    |> put_in(["properties", "eo:cloud_cover"], Keyword.get(opts, :cloud_cover, 90))
  end
end

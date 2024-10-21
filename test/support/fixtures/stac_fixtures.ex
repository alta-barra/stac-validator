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

  def valid_collection() do
    %{
      "type" => "Collection",
      "stac_version" => "1.1.0",
      "stac_extensions" => [],
      "id" => "sentinel-2",
      "title" => "Sentinel-2 MSI: MultiSpectral Instrument, Level-1C",
      "description" =>
        "Sentinel-2 is a wide-swath, high-resolution, multi-spectral\nimaging mission supporting Copernicus Land Monitoring studies,\nincluding the monitoring of vegetation, soil and water cover,\nas well as observation of inland waterways and coastal areas.\n\nThe Sentinel-2 data contain 13 UINT16 spectral bands representing\nTOA reflectance scaled by 10000. See the [Sentinel-2 User Handbook](https://sentinel.esa.int/documents/247904/685211/Sentinel-2_User_Handbook)\nfor details. In addition, three QA bands are present where one\n(QA60) is a bitmask band with cloud mask information. For more\ndetails, [see the full explanation of how cloud masks are computed.](https://sentinel.esa.int/web/sentinel/technical-guides/sentinel-2-msi/level-1c/cloud-masks)\n\nEach Sentinel-2 product (zip archive) may contain multiple\ngranules. Each granule becomes a separate Earth Engine asset.\nEE asset ids for Sentinel-2 assets have the following format:\nCOPERNICUS/S2/20151128T002653_20151128T102149_T56MNN. Here the\nfirst numeric part represents the sensing date and time, the\nsecond numeric part represents the product generation date and\ntime, and the final 6-character string is a unique granule identifier\nindicating its UTM grid reference (see [MGRS](https://en.wikipedia.org/wiki/Military_Grid_Reference_System)).\n\nFor more details on Sentinel-2 radiometric resoltuon, [see this page](https://earth.esa.int/web/sentinel/user-guides/sentinel-2-msi/resolutions/radiometric).\n",
      "license" => "other",
      "keywords" => [
        "copernicus",
        "esa",
        "eu",
        "msi",
        "radiance",
        "sentinel"
      ],
      "providers" => [
        %{
          "name" => "European Union/ESA/Copernicus",
          "roles" => [
            "producer",
            "licensor"
          ],
          "url" => "https://sentinel.esa.int/web/sentinel/user-guides/sentinel-2-msi"
        }
      ],
      "extent" => %{
        "spatial" => %{
          "bbox" => [
            [
              -180,
              -56,
              180,
              83
            ]
          ]
        },
        "temporal" => %{
          "interval" => [
            [
              "2015-06-23T00:00:00Z",
              nil
            ]
          ]
        }
      },
      "assets" => %{
        "metadata_iso_19139" => %{
          "roles" => [
            "metadata",
            "iso-19139"
          ],
          "href" =>
            "https://storage.googleapis.com/open-cogs/stac-examples/sentinel-2-iso-19139.xml",
          "title" => "ISO 19139 metadata",
          "type" => "application/vnd.iso.19139+xml"
        }
      },
      "links" => [
        %{
          "rel" => "parent",
          "href" => "../catalog.json",
          "type" => "application/json",
          "title" => "Example Catalog"
        },
        %{
          "rel" => "root",
          "href" => "../catalog.json",
          "type" => "application/json",
          "title" => "Example Catalog"
        },
        %{
          "rel" => "license",
          "href" =>
            "https://scihub.copernicus.eu/twiki/pub/SciHubWebPortal/TermsConditions/Sentinel_Data_Terms_and_Conditions.pdf",
          "title" => "Legal notice on the use of Copernicus Sentinel Data and Service Information"
        }
      ]
    }
  end
end

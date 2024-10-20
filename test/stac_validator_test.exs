defmodule StacValidatorTest do
  use ExUnit.Case
  doctest StacValidator

  import StacValidator.StacItemFixtures

  describe "validate_item/1" do
    setup do
      valid_item = valid_item()
      {:ok, valid_item: valid_item}
    end

    test "validates a valid STAC item", %{valid_item: item} do
      assert {:ok, true} = StacValidator.validate_item(item)
    end
  end
end

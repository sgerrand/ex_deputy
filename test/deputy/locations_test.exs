defmodule Deputy.LocationsTest do
  use ExUnit.Case, async: true

  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  # Create a test client for all tests
  setup do
    client =
      Deputy.new(
        base_url: "https://test.deputy.com",
        api_key: "test-key",
        http_client: Deputy.HTTPClient.Mock
      )

    {:ok, client: client}
  end

  describe "list/1" do
    test "returns list of locations", %{client: client} do
      response_body = [
        %{"Id" => 1, "CompanyName" => "Test Company 1"},
        %{"Id" => 2, "CompanyName" => "Test Company 2"}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/resource/Company"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Locations.list(client)
    end
  end

  describe "list_simplified/1" do
    test "returns simplified list of locations", %{client: client} do
      response_body = [
        %{"Id" => 1, "Name" => "Test Company 1"},
        %{"Id" => 2, "Name" => "Test Company 2"}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/company/simple"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Locations.list_simplified(client)
    end
  end

  describe "get/2" do
    test "returns a location by ID", %{client: client} do
      location_id = 123
      response_body = %{"Id" => location_id, "CompanyName" => "Test Company"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/my/location/#{location_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Locations.get(client, location_id)
    end
  end

  describe "get_settings/2" do
    test "returns settings for a location", %{client: client} do
      location_id = 123
      response_body = %{"WEEK_START" => 2, "CURRENCY" => "USD"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/company/#{location_id}/settings"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Locations.get_settings(client, location_id)
    end
  end

  describe "update_settings/3" do
    test "updates settings for a location", %{client: client} do
      location_id = 123
      settings = %{"WEEK_START" => 3}
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/company/#{location_id}/settings"

        assert Keyword.get(opts, :json) == settings

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} =
               Deputy.Locations.update_settings(client, location_id, settings)
    end
  end

  describe "update_all_settings/2" do
    test "updates settings for all locations", %{client: client} do
      settings = %{"WEEK_START" => 3}
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/company/all/settings"

        assert Keyword.get(opts, :json) == settings

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Locations.update_all_settings(client, settings)
    end
  end

  describe "create/2" do
    test "creates a new location", %{client: client} do
      attrs = %{
        strWorkplaceName: "New Location",
        strWorkplaceCode: "NLC",
        strAddress: "123 Test St",
        intIsWorkplace: 1,
        intIsPayrollEntity: 1,
        strTimezone: "America/New_York"
      }

      response_body = %{"Id" => 123}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :put
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/resource/Company"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Locations.create(client, attrs)
    end
  end

  describe "update/3" do
    test "updates a location", %{client: client} do
      location_id = 123
      attrs = %{strWorkplaceCode: "UPD"}
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/company/#{location_id}"

        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Locations.update(client, location_id, attrs)
    end
  end

  describe "archive/2" do
    test "archives a location", %{client: client} do
      location_id = 123
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/company/#{location_id}/archive"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Locations.archive(client, location_id)
    end
  end

  describe "delete/2" do
    test "deletes a location", %{client: client} do
      location_id = 123
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/company/#{location_id}/delete"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Locations.delete(client, location_id)
    end
  end

  describe "create_workplace/2" do
    test "creates a new workplace with areas", %{client: client} do
      attrs = %{
        strWorkplaceName: "New Workplace",
        strWorkplaceTimezone: "America/New_York",
        strAddress: "123 Test St",
        strLat: "40.7128",
        strLon: "-74.0060",
        intCountry: 1,
        arrAreaNames: ["Reception", "Kitchen"],
        strWorkplaceCode: "NWP",
        blnIsWorkplace: 1,
        blnIsPayrollEntity: 1
      }

      response_body = %{"Id" => 123}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/my/setup/addNewWorkplace"

        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Locations.create_workplace(client, attrs)
    end
  end
end

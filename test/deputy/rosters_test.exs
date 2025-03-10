defmodule Deputy.RostersTest do
  use ExUnit.Case, async: true

  import Mox, only: [expect: 3, verify_on_exit!: 1]

  setup :verify_on_exit!

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
    test "returns a list of rosters", %{client: client} do
      response_body = [
        %{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"},
        %{"Id" => 2, "StartTime" => "2023-01-01T10:00:00"}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/roster"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Rosters.list(client)
    end
  end

  describe "get/2" do
    test "returns a roster by ID", %{client: client} do
      roster_id = 123
      response_body = %{"Id" => roster_id, "StartTime" => "2023-01-01T09:00:00"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/roster/#{roster_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Rosters.get(client, roster_id)
    end
  end

  describe "get_by_date/2" do
    test "returns rosters for a specific date", %{client: client} do
      date = "2023-01-01"

      response_body = [
        %{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"},
        %{"Id" => 2, "StartTime" => "2023-01-01T10:00:00"}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/roster"
        assert Keyword.get(opts, :params) == %{date: date}

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Rosters.get_by_date(client, date)
    end
  end

  describe "get_by_date_and_location/3" do
    test "returns rosters for a specific date and location", %{client: client} do
      date = "2023-01-01"
      location_id = 456

      response_body = [
        %{"Id" => 1, "StartTime" => "2023-01-01T09:00:00", "CompanyId" => location_id},
        %{"Id" => 2, "StartTime" => "2023-01-01T10:00:00", "CompanyId" => location_id}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/roster"
        assert Keyword.get(opts, :params) == %{date: date, intCompanyId: location_id}

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} =
               Deputy.Rosters.get_by_date_and_location(client, date, location_id)
    end
  end

  describe "copy/2" do
    test "copies rosters from one date to another", %{client: client} do
      attrs = %{
        strFromDate: "2023-01-01",
        strToDate: "2023-01-08",
        intOperationalUnitArray: [1, 2],
        blnRequireErrorDetails: 1
      }

      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/roster/copy"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Rosters.copy(client, attrs)
    end
  end

  describe "publish/2" do
    test "publishes rosters", %{client: client} do
      attrs = %{
        intMode: 1,
        blnAllLocationsMode: 1,
        intRosterArray: [400]
      }

      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/roster/publish"

        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Rosters.publish(client, attrs)
    end
  end

  describe "create/2" do
    test "creates a new roster", %{client: client} do
      attrs = %{
        intEmployeeId: 1,
        intOperationalUnitId: 2,
        intCompanyId: 3,
        dtmStartTime: "2023-01-01 09:00:00",
        dtmEndTime: "2023-01-01 17:00:00"
      }

      response_body = %{"Id" => 123}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/roster/create"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Rosters.create(client, attrs)
    end
  end

  describe "discard/2" do
    test "discards rosters", %{client: client} do
      attrs = %{intRosterArray: [400]}
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/roster/discard"

        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Rosters.discard(client, attrs)
    end
  end

  describe "get_available_for_swap/1" do
    test "returns rosters available for swap", %{client: client} do
      response_body = [
        %{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"},
        %{"Id" => 2, "StartTime" => "2023-01-01T10:00:00"}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/roster/autobuild"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Rosters.get_available_for_swap(client)
    end
  end

  describe "get_recommendations/2" do
    test "returns recommendations for a roster", %{client: client} do
      roster_id = 123

      response_body = [
        %{"EmployeeId" => 456, "Score" => 85},
        %{"EmployeeId" => 789, "Score" => 72}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/getRecommendation/#{roster_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Rosters.get_recommendations(client, roster_id)
    end
  end
end

defmodule Deputy.TimesheetsTest do
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

  describe "start/2" do
    test "starts a timesheet", %{client: client} do
      attrs = %{
        intEmployeeId: 123,
        intCompanyId: 456
      }

      response_body = %{"Id" => 789}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/timesheet/start"

        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Timesheets.start(client, attrs)
    end
  end

  describe "stop/2" do
    test "stops a timesheet", %{client: client} do
      attrs = %{
        intTimesheetId: 123,
        intMealbreakMinute: 30
      }

      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/timesheet/end"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Timesheets.stop(client, attrs)
    end
  end

  describe "pause/2" do
    test "pauses a timesheet", %{client: client} do
      attrs = %{intTimesheetId: 123}
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/timesheet/pause"

        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Timesheets.pause(client, attrs)
    end
  end

  describe "get_details/2" do
    test "gets timesheet details by ID", %{client: client} do
      timesheet_id = 123
      response_body = %{"Id" => timesheet_id, "StartTime" => "2023-01-01T09:00:00"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/timesheet/#{timesheet_id}/details"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Timesheets.get_details(client, timesheet_id)
    end
  end

  describe "query/3" do
    test "gets a timesheet by ID", %{client: client} do
      timesheet_id = 123
      response_body = %{"Id" => timesheet_id, "StartTime" => "2023-01-01T09:00:00"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/resource/Timesheet/#{timesheet_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Timesheets.query(client, timesheet_id)
    end

    test "searches for timesheets using query", %{client: client} do
      query = %{
        search: %{id: %{field: "Id", type: "eq", data: 1}},
        join: ["TimesheetObject"]
      }

      response_body = [
        %{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/resource/Timesheet/QUERY"

        assert Keyword.get(opts, :json) == query

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Timesheets.query(client, nil, query)
    end

    test "gets a timesheet by ID with query parameters", %{client: client} do
      timesheet_id = 123
      query = %{join: ["TimesheetObject"]}

      response_body = %{"Id" => timesheet_id, "StartTime" => "2023-01-01T09:00:00"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/resource/Timesheet/#{timesheet_id}"

        assert Keyword.get(opts, :json) == query

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Timesheets.query(client, timesheet_id, query)
    end
  end
end

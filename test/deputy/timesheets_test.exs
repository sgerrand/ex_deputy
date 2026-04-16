defmodule Deputy.TimesheetsTest do
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

    test "returns validation error when intEmployeeId is missing", %{client: client} do
      attrs = %{intCompanyId: 2}

      assert {:error, %Deputy.Error.ValidationError{field: :intEmployeeId}} =
               Deputy.Timesheets.start(client, attrs)
    end

    test "returns validation error when intCompanyId is missing", %{client: client} do
      attrs = %{intEmployeeId: 1}

      assert {:error, %Deputy.Error.ValidationError{field: :intCompanyId}} =
               Deputy.Timesheets.start(client, attrs)
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

  describe "start!/2" do
    test "returns unwrapped timesheet on start", %{client: client} do
      attrs = %{intEmployeeId: 1, intCompanyId: 2}
      response_body = %{"Id" => 789}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/timesheet/start"

        {:ok, response_body}
      end)

      assert ^response_body = Deputy.Timesheets.start!(client, attrs)
    end
  end

  describe "error handling" do
    test "returns API error for 422 response", %{client: client} do
      attrs = %{intEmployeeId: 1, intCompanyId: 2}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        {:error,
         Deputy.Error.from_response(%{
           status: 422,
           body: %{"message" => "Employee is already clocked in"}
         })}
      end)

      assert {:error,
              %Deputy.Error.APIError{status: 422, message: "Employee is already clocked in"}} =
               Deputy.Timesheets.start(client, attrs)
    end

    test "returns HTTP error for 500 response", %{client: client} do
      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        {:error, Deputy.Error.from_response(%{status: 500, body: "Internal Server Error"})}
      end)

      assert {:error, %Deputy.Error.HTTPError{status: 500}} =
               Deputy.Timesheets.get_details(client, 1)
    end

    test "returns rate limit error for 429 response", %{client: client} do
      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        {:error, Deputy.Error.from_response(%{status: 429, body: %{"retry_after" => 60}})}
      end)

      assert {:error, %Deputy.Error.RateLimitError{retry_after: 60}} =
               Deputy.Timesheets.get_details(client, 1)
    end
  end
end

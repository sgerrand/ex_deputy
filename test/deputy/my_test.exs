defmodule Deputy.MyTest do
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

  describe "me/1" do
    test "retrieves user information", %{client: client} do
      response_body = %{"Id" => 1, "FirstName" => "John", "LastName" => "Doe"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/me"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.me(client)
    end
  end

  describe "setup/1" do
    test "retrieves setup information", %{client: client} do
      response_body = %{"locations" => [%{"Id" => 1, "Name" => "Main Office"}]}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/setup"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.setup(client)
    end
  end

  describe "locations/1" do
    test "retrieves user's locations", %{client: client} do
      response_body = [
        %{"Id" => 1, "Name" => "Main Office"},
        %{"Id" => 2, "Name" => "Branch Office"}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/location"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.locations(client)
    end
  end

  describe "location/2" do
    test "retrieves a specific location", %{client: client} do
      location_id = 123
      response_body = %{"Id" => location_id, "Name" => "Main Office"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/my/location/#{location_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.location(client, location_id)
    end
  end

  describe "contact_address/1" do
    test "retrieves user's contact address", %{client: client} do
      response_body = %{"Street1" => "123 Main St", "City" => "New York"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/contactaddress"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.contact_address(client)
    end
  end

  describe "all_contact_addresses/1" do
    test "retrieves all user's contact addresses", %{client: client} do
      response_body = [%{"Street1" => "123 Main St", "City" => "New York"}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/contactaddress/all"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.all_contact_addresses(client)
    end
  end

  describe "update_contact_address/2" do
    test "updates user's contact address", %{client: client} do
      attrs = %{
        ContactName: "John Doe",
        UnitNo: "2",
        Street1: "123 Main St",
        City: "New York",
        State: "NY",
        Postcode: "10001",
        Country: 1
      }

      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/contactaddress"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.update_contact_address(client, attrs)
    end
  end

  describe "colleagues/1" do
    test "retrieves user's colleagues", %{client: client} do
      response_body = [%{"Id" => 2, "FirstName" => "Jane", "LastName" => "Smith"}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/colleague"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.colleagues(client)
    end
  end

  describe "rosters/1" do
    test "retrieves user's rosters", %{client: client} do
      response_body = [%{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/roster"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.rosters(client)
    end
  end

  describe "leave/1" do
    test "retrieves user's leave requests", %{client: client} do
      response_body = [%{"Id" => 1, "DateStart" => "2023-01-01", "DateEnd" => "2023-01-05"}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/leave"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.leave(client)
    end
  end

  describe "unavailability/1" do
    test "retrieves user's unavailability", %{client: client} do
      response_body = [%{"Id" => 1, "Start" => %{"timestamp" => 1_657_001_675}}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/unavail"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.unavailability(client)
    end
  end

  describe "notifications/1" do
    test "retrieves user's notifications", %{client: client} do
      response_body = [%{"Id" => 1, "Message" => "You have a new roster"}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/notification"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.notifications(client)
    end
  end

  describe "training/1" do
    test "retrieves user's training", %{client: client} do
      response_body = [%{"Id" => 1, "Name" => "Safety Training"}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/training"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.training(client)
    end
  end

  describe "memos/1" do
    test "retrieves user's memos", %{client: client} do
      response_body = [%{"Id" => 1, "Content" => "Welcome to Deputy"}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/memo"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.memos(client)
    end
  end

  describe "tasks/1" do
    test "retrieves user's tasks", %{client: client} do
      response_body = [%{"Id" => 1, "TaskName" => "Complete training"}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/tasks"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.tasks(client)
    end
  end

  describe "complete_task/2" do
    test "completes a task", %{client: client} do
      task_id = 123
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/tasks/#{task_id}/do"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.complete_task(client, task_id)
    end
  end

  describe "timesheets/1" do
    test "retrieves user's timesheets", %{client: client} do
      response_body = [%{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/timesheets"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.timesheets(client)
    end
  end

  describe "timesheet_detail/2" do
    test "retrieves details for a specific timesheet", %{client: client} do
      timesheet_id = 123
      response_body = %{"Id" => timesheet_id, "StartTime" => "2023-01-01T09:00:00"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/my/timesheets/#{timesheet_id}/detail"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.My.timesheet_detail(client, timesheet_id)
    end
  end
end

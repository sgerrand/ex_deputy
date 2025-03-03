defmodule Deputy.EmployeesTest do
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
    test "returns list of employees", %{client: client} do
      response_body = [
        %{"Id" => 1, "FirstName" => "John", "LastName" => "Doe"},
        %{"Id" => 2, "FirstName" => "Jane", "LastName" => "Smith"}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/employee"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.list(client)
    end
  end

  describe "get/2" do
    test "returns an employee by ID", %{client: client} do
      employee_id = 123
      response_body = %{"Id" => employee_id, "FirstName" => "John", "LastName" => "Doe"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/employee/#{employee_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.get(client, employee_id)
    end
  end

  describe "create/2" do
    test "creates a new employee", %{client: client} do
      attrs = %{
        strFirstName: "John",
        strLastName: "Doe",
        intCompanyId: 1,
        intGender: 1,
        strCountryCode: "US",
        strDob: "1980-01-01",
        strStartDate: "2023-01-01",
        strMobilePhone: "5551234567"
      }

      response_body = %{"Id" => 123}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/employee"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.create(client, attrs)
    end
  end

  describe "update/3" do
    test "updates an employee", %{client: client} do
      employee_id = 123
      attrs = %{Phone: "5559876543"}
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/employee/#{employee_id}"

        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.update(client, employee_id, attrs)
    end
  end

  describe "add_location/3" do
    test "adds a location to an employee", %{client: client} do
      employee_id = 123
      company_id = 456
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/employee/#{employee_id}/assoc/#{company_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} =
               Deputy.Employees.add_location(client, employee_id, company_id)
    end
  end

  describe "remove_location/3" do
    test "removes a location from an employee", %{client: client} do
      employee_id = 123
      company_id = 456
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/employee/#{employee_id}/unassoc/#{company_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} =
               Deputy.Employees.remove_location(client, employee_id, company_id)
    end
  end

  describe "terminate/2" do
    test "terminates an employee", %{client: client} do
      employee_id = 123
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/employee/#{employee_id}/terminate"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.terminate(client, employee_id)
    end
  end

  describe "reactivate/2" do
    test "reactivates a terminated employee", %{client: client} do
      employee_id = 123
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/employee/#{employee_id}/activate"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.reactivate(client, employee_id)
    end
  end

  describe "delete/2" do
    test "deletes an employee", %{client: client} do
      employee_id = 123
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/employee/#{employee_id}/delete"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.delete(client, employee_id)
    end
  end

  describe "invite/2" do
    test "invites an employee to Deputy", %{client: client} do
      employee_id = 123
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/employee/#{employee_id}/invite"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.invite(client, employee_id)
    end
  end

  describe "set_award/3" do
    test "sets an award for an employee", %{client: client} do
      employee_id = 123
      attrs = %{strCountryCode: "au", strAwardCode: "casual-2021-11-01-aea-2"}
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/employee/#{employee_id}/setAwardFromLibrary"

        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.set_award(client, employee_id, attrs)
    end
  end

  describe "get_shift_info/2" do
    test "gets an employee's shift information", %{client: client} do
      employee_id = 123
      response_body = %{"Status" => "On Shift", "RosterID" => 456}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/empshiftinfo/#{employee_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.get_shift_info(client, employee_id)
    end
  end

  describe "get_leave/2" do
    test "gets an employee's leave", %{client: client} do
      employee_id = 123

      response_body = [
        %{"Id" => 456, "DateStart" => "2023-01-01", "DateEnd" => "2023-01-05"}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/leave/#{employee_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.get_leave(client, employee_id)
    end
  end

  describe "add_leave/2" do
    test "adds leave for an employee", %{client: client} do
      attrs = %{
        Status: 1,
        Employee: 123,
        DateStart: "2023/01/01",
        DateEnd: "2023/01/05",
        ApprovalComment: "Vacation",
        ActionOverlappingRosters: 0
      }

      response_body = %{"Id" => 456}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/leave/"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.add_leave(client, attrs)
    end
  end

  describe "get_unavailability/2" do
    test "gets an employee's unavailability", %{client: client} do
      employee_id = 123

      response_body = [
        %{
          "Id" => 456,
          "Start" => %{"timestamp" => 1_657_001_675},
          "End" => %{"timestamp" => 1_657_001_676}
        }
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/unavail/#{employee_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.get_unavailability(client, employee_id)
    end
  end

  describe "add_unavailability/2" do
    test "adds unavailability for an employee", %{client: client} do
      attrs = %{
        employee: 123,
        start: %{timestamp: 1_657_001_675},
        end: %{timestamp: 1_657_001_676},
        strComment: "Weekly appointment",
        recurrence: %{FREQ: "WEEKLY", INTERVAL: 1, BYDAY: "MO"}
      }

      response_body = %{"Id" => 456}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/unavail/"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.add_unavailability(client, attrs)
    end
  end

  describe "add_journal/2" do
    test "adds a journal entry for an employee", %{client: client} do
      attrs = %{
        strComment: "Employee performed well today",
        intEmployeeId: 123
      }

      response_body = %{"Id" => 456}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/journal"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.add_journal(client, attrs)
    end
  end

  describe "get_agreed_hours/2" do
    test "gets an employee's agreed hours", %{client: client} do
      employee_id = 123
      response_body = %{"AgreedHours" => 40.0}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/management/v2/agreed_hour/#{employee_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Employees.get_agreed_hours(client, employee_id)
    end
  end
end

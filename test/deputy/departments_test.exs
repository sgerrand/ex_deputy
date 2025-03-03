defmodule Deputy.DepartmentsTest do
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

  describe "create/2" do
    test "creates a new department", %{client: client} do
      attrs = %{
        intCompanyId: 1,
        strOpunitName: "Sales",
        strAddress: "123 Main St",
        intOpunitType: 1
      }

      response_body = %{"Id" => 123}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :put
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/department"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Departments.create(client, attrs)
    end
  end

  describe "create_multiple/2" do
    test "creates multiple departments", %{client: client} do
      attrs = %{
        arrArea: [
          %{
            intCompanyId: 1,
            strOpunitName: "Sales",
            strAddress: "123 Main St",
            intOpunitType: 1
          },
          %{
            intCompanyId: 1,
            strOpunitName: "Marketing",
            strAddress: "123 Main St",
            intOpunitType: 1
          }
        ]
      }

      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :put

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/supervise/department/create/"

        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Departments.create_multiple(client, attrs)
    end
  end

  describe "list/1" do
    test "returns a list of departments", %{client: client} do
      response_body = [
        %{"Id" => 1, "OpunitName" => "Sales"},
        %{"Id" => 2, "OpunitName" => "Marketing"}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/resource/OperationalUnit/"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Departments.list(client)
    end
  end

  describe "delete/2" do
    test "deletes a department", %{client: client} do
      department_id = 123
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :delete

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/resource/OperationalUnit/#{department_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Departments.delete(client, department_id)
    end
  end

  describe "update/3" do
    test "updates a department", %{client: client} do
      department_id = 20

      attrs = %{
        intCompanyId: 12,
        strOpunitName: "Updated Department Name"
      }

      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/resource/OperationalUnit/#{department_id}"

        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Departments.update(client, department_id, attrs)
    end
  end

  describe "query/2" do
    test "queries departments with specific criteria", %{client: client} do
      query = %{
        join: [],
        assoc: ["RosterEmployeeOperationalUnit"],
        search: %{id: %{field: "Id", type: "eq", data: 1}}
      }

      response_body = [
        %{
          "Id" => 1,
          "OpunitName" => "Sales",
          "Employees" => [%{"Id" => 123, "FirstName" => "John"}]
        }
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post

        assert Keyword.get(opts, :url) ==
                 "https://test.deputy.com/api/v1/resource/OperationalUnit/QUERY"

        assert Keyword.get(opts, :json) == query

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Departments.query(client, query)
    end
  end
end

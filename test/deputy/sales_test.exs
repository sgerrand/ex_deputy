defmodule Deputy.SalesTest do
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

  describe "add_metrics/2" do
    test "adds sales metrics", %{client: client} do
      metrics = %{
        data: [
          %{
            timestamp: 1_660_272_300,
            area: 2,
            type: "Sales",
            reference: "API-Sales-Entry-1660272300",
            value: 100.30,
            employee: 1,
            location: 1
          }
        ]
      }

      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v2/metrics"
        assert Keyword.get(opts, :json) == metrics

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Sales.add_metrics(client, metrics)
    end
  end

  describe "get_metrics/2" do
    test "retrieves sales data", %{client: client} do
      params = %{
        areas: "1",
        types: "Sales",
        start: "1626203567",
        end: "1657775576"
      }

      response_body = [
        %{"timestamp" => 1_626_203_600, "area" => 1, "type" => "Sales", "value" => 100.30}
      ]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v2/metrics/raw"
        assert Keyword.get(opts, :params) == params

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Sales.get_metrics(client, params)
    end
  end

  describe "add_metrics!/2" do
    test "returns unwrapped add result", %{client: client} do
      metrics = %{data: [%{timestamp: 1_660_272_300, area: 2, type: "Sales", value: 100.0}]}
      response_body = %{"success" => true}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v2/metrics"
        {:ok, response_body}
      end)

      assert ^response_body = Deputy.Sales.add_metrics!(client, metrics)
    end
  end

  describe "get_metrics!/2" do
    test "returns unwrapped metrics list", %{client: client} do
      params = %{areas: "1", types: "Sales", start: "1626203567", end: "1657775576"}
      response_body = [%{"timestamp" => 1_626_203_600, "type" => "Sales", "value" => 100.30}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v2/metrics/raw"
        {:ok, response_body}
      end)

      assert ^response_body = Deputy.Sales.get_metrics!(client, params)
    end
  end

  describe "error handling" do
    test "returns API error for 400 response", %{client: client} do
      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        {:error,
         Deputy.Error.from_response(%{status: 400, body: %{"message" => "Invalid metric data"}})}
      end)

      assert {:error, %Deputy.Error.APIError{status: 400, message: "Invalid metric data"}} =
               Deputy.Sales.add_metrics(client, %{data: []})
    end

    test "returns HTTP error for 500 response", %{client: client} do
      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        {:error, Deputy.Error.from_response(%{status: 500, body: "Internal Server Error"})}
      end)

      assert {:error, %Deputy.Error.HTTPError{status: 500}} =
               Deputy.Sales.get_metrics(client, %{})
    end

    test "returns rate limit error for 429 response", %{client: client} do
      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        {:error, Deputy.Error.from_response(%{status: 429, body: %{"retry_after" => 60}})}
      end)

      assert {:error, %Deputy.Error.RateLimitError{retry_after: 60}} =
               Deputy.Sales.get_metrics(client, %{})
    end
  end
end

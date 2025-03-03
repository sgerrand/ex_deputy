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
end

defmodule DeputyTest do
  use ExUnit.Case
  doctest Deputy

  import Mox

  setup :verify_on_exit!

  describe "new/1" do
    test "creates a new client with valid options" do
      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")

      assert %Deputy{} = client
      assert client.base_url == "https://test.deputy.com"
      assert client.api_key == "test-key"
      assert client.http_client == Deputy.HTTPClient.Req
    end

    test "creates a new client with custom HTTP client" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      assert client.http_client == Deputy.HTTPClient.Mock
    end

    test "raises an error when missing required options" do
      assert_raise KeyError, fn ->
        Deputy.new([])
      end

      assert_raise KeyError, fn ->
        Deputy.new(base_url: "https://test.deputy.com")
      end

      assert_raise KeyError, fn ->
        Deputy.new(api_key: "test-key")
      end
    end
  end

  describe "request/4" do
    test "builds proper request parameters and handles success response" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/test/path"
        assert Keyword.get(opts, :headers) == [{"Authorization", "Bearer test-key"}]
        assert Keyword.get(opts, :params) == %{query: "param"}

        {:ok, %{"data" => "success"}}
      end)

      result = Deputy.request(client, :get, "/test/path", params: %{query: "param"})

      assert result == {:ok, %{"data" => "success"}}
    end

    test "properly handles error responses" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        {:error, %{status: 404, body: %{"error" => "not found"}}}
      end)

      result = Deputy.request(client, :get, "/test/path")

      assert result == {:error, %{status: 404, body: %{"error" => "not found"}}}
    end

    test "properly handles request with a body" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      body = %{name: "Test Location", code: "TST"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        # Verify the request body is included
        assert Keyword.get(opts, :json) == body

        {:ok, %{"id" => 123}}
      end)

      result = Deputy.request(client, :post, "/test/path", body: body)

      assert result == {:ok, %{"id" => 123}}
    end
  end
end

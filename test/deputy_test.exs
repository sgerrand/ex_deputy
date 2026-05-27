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

    test "defaults auth_scheme to :bearer" do
      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      assert client.auth_scheme == :bearer
    end

    test "accepts :oauth auth_scheme" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          auth_scheme: :oauth
        )

      assert client.auth_scheme == :oauth
    end

    test "accepts :dpauth auth_scheme" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          auth_scheme: :dpauth
        )

      assert client.auth_scheme == :dpauth
    end

    test "raises ArgumentError for unknown auth_scheme" do
      assert_raise ArgumentError, ~r/invalid :auth_scheme/, fn ->
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          auth_scheme: :basic
        )
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
      |> expect(:request, fn req ->
        assert req.method == :get
        assert req.url == "https://test.deputy.com/test/path"
        assert req.headers == [{"Authorization", "Bearer test-key"}]
        assert req.params == %{query: "param"}

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
      |> expect(:request, fn _req ->
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
      |> expect(:request, fn req ->
        # Verify the request body is included
        assert req.body == body

        {:ok, %{"id" => 123}}
      end)

      result = Deputy.request(client, :post, "/test/path", body: body)

      assert result == {:ok, %{"id" => 123}}
    end

    test "returns validation error for invalid params" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      result = Deputy.request(client, :get, "/test/path", params: "invalid")

      assert {:error, %Deputy.Error.ValidationError{field: :params}} = result
    end

    test "returns validation error for invalid body" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      result = Deputy.request(client, :post, "/test/path", body: "invalid")

      assert {:error, %Deputy.Error.ValidationError{field: :body}} = result
    end

    test "accepts list as body" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      body = [%{name: "item1"}, %{name: "item2"}]

      Deputy.HTTPClient.Mock
      |> expect(:request, fn req ->
        assert req.body == body
        {:ok, %{"id" => 123}}
      end)

      assert {:ok, _} = Deputy.request(client, :post, "/test/path", body: body)
    end

    test "accepts list as params" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      Deputy.HTTPClient.Mock
      |> expect(:request, fn req ->
        assert req.params == [key: "value"]
        {:ok, []}
      end)

      assert {:ok, _} = Deputy.request(client, :get, "/test/path", params: [key: "value"])
    end

    test "sends OAuth scheme Authorization header" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "oauth-token",
          http_client: Deputy.HTTPClient.Mock,
          auth_scheme: :oauth
        )

      Deputy.HTTPClient.Mock
      |> expect(:request, fn req ->
        assert req.headers == [{"Authorization", "OAuth oauth-token"}]
        {:ok, %{}}
      end)

      assert {:ok, _} = Deputy.request(client, :get, "/test/path")
    end

    test "forwards :retry option to the HTTP client" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      Deputy.HTTPClient.Mock
      |> expect(:request, fn req ->
        assert req.retry == :safe_transient
        {:ok, %{}}
      end)

      assert {:ok, _} =
               Deputy.request(client, :get, "/test/path", retry: :safe_transient)
    end

    test "does not include :retry option when absent" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      Deputy.HTTPClient.Mock
      |> expect(:request, fn req ->
        assert is_nil(req.retry)
        {:ok, %{}}
      end)

      assert {:ok, _} = Deputy.request(client, :get, "/test/path")
    end

    test "sends dpauth header for permanent tokens" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "perm-token",
          http_client: Deputy.HTTPClient.Mock,
          auth_scheme: :dpauth
        )

      Deputy.HTTPClient.Mock
      |> expect(:request, fn req ->
        assert req.headers == [{"dpauth", "perm-token"}]
        {:ok, %{}}
      end)

      assert {:ok, _} = Deputy.request(client, :get, "/test/path")
    end
  end
end

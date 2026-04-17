defmodule Deputy.UtilityTest do
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

  describe "get_time/1" do
    test "retrieves current system time", %{client: client} do
      response_body = %{"time" => 1_672_531_200, "tz" => "UTC"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/time"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Utility.get_time(client)
    end
  end

  describe "get_location_time/2" do
    test "retrieves time for a specific location", %{client: client} do
      location_id = 123
      response_body = %{"time" => 1_672_531_200, "tz" => "America/New_York"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/time/#{location_id}"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Utility.get_location_time(client, location_id)
    end
  end

  describe "create_memo/2" do
    test "creates a memo", %{client: client} do
      attrs = %{
        strContent: "Hello, this is a memo",
        intCompany: 1,
        blnRequireConfirm: 0
      }

      response_body = %{"Id" => 123}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :put
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/memo"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Utility.create_memo(client, attrs)
    end
  end

  describe "add_webhook/2" do
    test "adds a webhook", %{client: client} do
      attrs = %{
        Topic: "Timesheet.Insert",
        Enabled: 1,
        Type: "URL",
        Address: "https://example.com/webhook"
      }

      response_body = %{"Id" => 123}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :post
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/resource/Webhook"
        assert Keyword.get(opts, :json) == attrs

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Utility.add_webhook(client, attrs)
    end
  end

  describe "who_am_i/1" do
    test "retrieves information about the authenticated user", %{client: client} do
      response_body = %{"Id" => 1, "FirstName" => "John", "LastName" => "Doe"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/me"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Utility.who_am_i(client)
    end
  end

  describe "get_setup/1" do
    test "retrieves setup information for the authenticated user", %{client: client} do
      response_body = %{"locations" => [%{"Id" => 1, "Name" => "Main Office"}]}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/setup"

        {:ok, response_body}
      end)

      assert {:ok, ^response_body} = Deputy.Utility.get_setup(client)
    end
  end

  describe "get_time!/1" do
    test "returns unwrapped system time", %{client: client} do
      response_body = %{"time" => 1_672_531_200, "tz" => "UTC"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :method) == :get
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/time"
        {:ok, response_body}
      end)

      assert ^response_body = Deputy.Utility.get_time!(client)
    end
  end

  describe "get_location_time!/2" do
    test "returns unwrapped location time", %{client: client} do
      location_id = 123
      response_body = %{"time" => 1_672_531_200, "tz" => "America/New_York"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/time/#{location_id}"
        {:ok, response_body}
      end)

      assert ^response_body = Deputy.Utility.get_location_time!(client, location_id)
    end
  end

  describe "create_memo!/2" do
    test "returns unwrapped created memo", %{client: client} do
      attrs = %{strContent: "Hello", intCompany: 1, blnRequireConfirm: 0}
      response_body = %{"Id" => 123}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/memo"
        {:ok, response_body}
      end)

      assert ^response_body = Deputy.Utility.create_memo!(client, attrs)
    end
  end

  describe "add_webhook!/2" do
    test "returns unwrapped created webhook", %{client: client} do
      attrs = %{
        Topic: "Timesheet.Insert",
        Enabled: 1,
        Type: "URL",
        Address: "https://example.com"
      }

      response_body = %{"Id" => 123}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/resource/Webhook"
        {:ok, response_body}
      end)

      assert ^response_body = Deputy.Utility.add_webhook!(client, attrs)
    end
  end

  describe "who_am_i!/1" do
    test "returns unwrapped user info", %{client: client} do
      response_body = %{"Id" => 1, "FirstName" => "John"}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/me"
        {:ok, response_body}
      end)

      assert ^response_body = Deputy.Utility.who_am_i!(client)
    end
  end

  describe "get_setup!/1" do
    test "returns unwrapped setup info", %{client: client} do
      response_body = %{"locations" => []}

      Deputy.HTTPClient.Mock
      |> expect(:request, fn opts ->
        assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/my/setup"
        {:ok, response_body}
      end)

      assert ^response_body = Deputy.Utility.get_setup!(client)
    end
  end

  describe "error handling" do
    test "returns API error for 401 response", %{client: client} do
      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        {:error, Deputy.Error.from_response(%{status: 401, body: %{"message" => "Unauthorized"}})}
      end)

      assert {:error, %Deputy.Error.APIError{status: 401, message: "Unauthorized"}} =
               Deputy.Utility.who_am_i(client)
    end

    test "returns HTTP error for 500 response", %{client: client} do
      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        {:error, Deputy.Error.from_response(%{status: 500, body: "Internal Server Error"})}
      end)

      assert {:error, %Deputy.Error.HTTPError{status: 500}} = Deputy.Utility.get_time(client)
    end

    test "returns rate limit error for 429 response", %{client: client} do
      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        {:error, Deputy.Error.from_response(%{status: 429, body: %{"retry_after" => 60}})}
      end)

      assert {:error, %Deputy.Error.RateLimitError{retry_after: 60}} =
               Deputy.Utility.get_time(client)
    end
  end
end

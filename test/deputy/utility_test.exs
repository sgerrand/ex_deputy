defmodule Deputy.UtilityTest do
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
end

defmodule Deputy.ErrorTest do
  use ExUnit.Case, async: true

  alias Deputy.Error
  alias Deputy.Error.{API, HTTP, ParseError, ValidationError, RateLimitError}

  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "from_response/1" do
    test "creates an API error for 4xx responses with error code and message" do
      response = %{
        status: 400,
        body: %{
          "error" => %{
            "code" => "invalid_parameter",
            "message" => "Invalid parameter value"
          },
          "details" => %{"field" => "employee_id"}
        }
      }

      error = Error.from_response(response)

      assert %API{} = error
      assert error.status == 400
      assert error.code == "invalid_parameter"
      assert error.message == "Invalid parameter value"
      assert error.details == %{"field" => "employee_id"}
    end

    test "creates an API error for 4xx responses with simple message" do
      response = %{
        status: 404,
        body: %{
          "message" => "Resource not found",
          "resource_type" => "employee"
        }
      }

      error = Error.from_response(response)

      assert %API{} = error
      assert error.status == 404
      assert error.code == nil
      assert error.message == "Resource not found"
      assert error.details == %{"resource_type" => "employee"}
    end

    test "creates an HTTP error for 4xx responses without structured error information" do
      response = %{
        status: 400,
        body: "Bad request format"
      }

      error = Error.from_response(response)

      assert %HTTP{} = error
      assert error.status == 400
      assert error.reason == "Bad request"
      assert error.body == "Bad request format"
    end

    test "creates a RateLimitError for 429 status" do
      response = %{
        status: 429,
        body: %{
          "retry_after" => 60,
          "rate_limit" => 100,
          "rate_remaining" => 0
        }
      }

      error = Error.from_response(response)

      assert %RateLimitError{} = error
      assert error.retry_after == 60
      assert error.limit == 100
      assert error.remaining == 0
    end

    test "creates a RateLimitError for 429 status with camelCase" do
      response = %{
        status: 429,
        body: %{
          "retryAfter" => 30,
          "rateLimit" => 200,
          "rateRemaining" => 0
        }
      }

      error = Error.from_response(response)

      assert %RateLimitError{} = error
      assert error.retry_after == 30
      assert error.limit == 200
      assert error.remaining == 0
    end

    test "creates an HTTP error for 5xx responses" do
      response = %{
        status: 500,
        body: %{"message" => "Internal server error"}
      }

      error = Error.from_response(response)

      assert %HTTP{} = error
      assert error.status == 500
      assert error.reason == "Server error"
      assert error.body == %{"message" => "Internal server error"}
    end

    test "creates an HTTP error for unexpected errors" do
      error = Error.from_response(:timeout)

      assert %HTTP{} = error
      assert error.status == nil
      assert error.reason == :timeout
      assert error.body == nil
    end
  end

  describe "error structs formatting" do
    test "API error message formatting" do
      error = %API{
        status: 403,
        code: "forbidden",
        message: "You don't have permission to access this resource"
      }

      assert Exception.message(error) ==
               "Deputy API error (Status: 403, Code: forbidden): You don't have permission to access this resource"
    end

    test "API error message formatting without code" do
      error = %API{
        status: 404,
        message: "Resource not found"
      }

      assert Exception.message(error) == "Deputy API error (Status: 404): Resource not found"
    end

    test "HTTP error message formatting with status" do
      error = %HTTP{
        reason: "connection_failed",
        status: 503
      }

      assert Exception.message(error) == "HTTP error (Status: 503): \"connection_failed\""
    end

    test "HTTP error message formatting without status" do
      error = %HTTP{
        reason: :timeout
      }

      assert Exception.message(error) == "HTTP error: :timeout"
    end

    test "ParseError message formatting" do
      error = %ParseError{
        message: "Invalid JSON format",
        raw_data: "{invalid: json"
      }

      assert Exception.message(error) == "Parse error: Invalid JSON format"
    end

    test "ValidationError message formatting with field" do
      error = %ValidationError{
        message: "Value must be positive",
        field: :employee_id,
        value: -1
      }

      assert Exception.message(error) ==
               "Validation error for field 'employee_id': Value must be positive"
    end

    test "ValidationError message formatting without field" do
      error = %ValidationError{
        message: "Invalid request structure"
      }

      assert Exception.message(error) == "Validation error: Invalid request structure"
    end

    test "RateLimitError message formatting with retry_after" do
      error = %RateLimitError{
        retry_after: 60,
        limit: 100,
        remaining: 0
      }

      assert Exception.message(error) == "Rate limit exceeded. Retry after 60 seconds."
    end

    test "RateLimitError message formatting without retry_after" do
      error = %RateLimitError{
        limit: 100,
        remaining: 0
      }

      assert Exception.message(error) == "Rate limit exceeded."
    end
  end

  describe "bang functions" do
    test "request! raises API error" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        error = Error.from_response(%{status: 403, body: %{"message" => "Access denied"}})
        {:error, error}
      end)

      api_error = %API{status: 403, message: "Access denied"}

      assert_raise API, Exception.message(api_error), fn ->
        Deputy.request!(client, :get, "/test/path")
      end
    end

    test "request! raises HTTP error" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key",
          http_client: Deputy.HTTPClient.Mock
        )

      Deputy.HTTPClient.Mock
      |> expect(:request, fn _opts ->
        error = Error.from_response(%{status: 503, body: "Service unavailable"})
        {:error, error}
      end)

      assert_raise HTTP, fn ->
        Deputy.request!(client, :get, "/test/path")
      end
    end

    test "request! raises ValidationError" do
      client =
        Deputy.new(
          base_url: "https://test.deputy.com",
          api_key: "test-key"
        )

      invalid_body = "not a map"

      assert_raise ValidationError, fn ->
        Deputy.request!(client, :post, "/test/path", body: invalid_body)
      end
    end
  end
end

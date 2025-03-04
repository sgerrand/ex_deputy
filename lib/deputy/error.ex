defmodule Deputy.Error do
  @moduledoc """
  Defines error types for Deputy API client operations.

  This module provides standardized error structs for different types of errors that can occur
  when interacting with the Deputy API, making error handling more specific and easier to manage.
  """

  @type t ::
          Deputy.Error.API.t()
          | Deputy.Error.HTTP.t()
          | Deputy.Error.ParseError.t()
          | Deputy.Error.ValidationError.t()

  defmodule API do
    @moduledoc """
    Represents an error returned by the Deputy API.
    """
    defexception [:status, :code, :message, :details]

    @type t :: %__MODULE__{
            status: integer(),
            code: String.t() | nil,
            message: String.t(),
            details: map() | nil
          }

    def message(%__MODULE__{message: message, code: code, status: status}) do
      "Deputy API error (Status: #{status}#{code_str(code)}): #{message}"
    end

    defp code_str(nil), do: ""
    defp code_str(code), do: ", Code: #{code}"
  end

  defmodule HTTP do
    @moduledoc """
    Represents an HTTP-level error that occurred while communicating with the Deputy API.
    """
    defexception [:reason, :status, :body]

    @type t :: %__MODULE__{
            reason: atom() | String.t(),
            status: integer() | nil,
            body: map() | String.t() | nil
          }

    def message(%__MODULE__{reason: reason, status: status}) when is_nil(status) do
      "HTTP error: #{inspect(reason)}"
    end

    def message(%__MODULE__{reason: reason, status: status}) do
      "HTTP error (Status: #{status}): #{inspect(reason)}"
    end
  end

  defmodule ParseError do
    @moduledoc """
    Represents an error that occurred while parsing the API response.
    """
    defexception [:message, :raw_data]

    @type t :: %__MODULE__{
            message: String.t(),
            raw_data: any()
          }

    def message(%__MODULE__{message: message}) do
      "Parse error: #{message}"
    end
  end

  defmodule ValidationError do
    @moduledoc """
    Represents an error that occurred while validating request parameters.
    """
    defexception [:message, :field, :value]

    @type t :: %__MODULE__{
            message: String.t(),
            field: atom() | nil,
            value: any()
          }

    def message(%__MODULE__{message: message, field: nil}) do
      "Validation error: #{message}"
    end

    def message(%__MODULE__{message: message, field: field}) do
      "Validation error for field '#{field}': #{message}"
    end
  end

  defmodule RateLimitError do
    @moduledoc """
    Represents a rate limit error from the Deputy API.
    """
    defexception [:retry_after, :limit, :remaining]

    @type t :: %__MODULE__{
            retry_after: integer() | nil,
            limit: integer() | nil,
            remaining: integer() | nil
          }

    def message(%__MODULE__{retry_after: retry_after}) when not is_nil(retry_after) do
      "Rate limit exceeded. Retry after #{retry_after} seconds."
    end

    def message(%__MODULE__{}) do
      "Rate limit exceeded."
    end
  end

  @doc """
  Converts a raw HTTP error response into the appropriate error struct.

  This function analyzes the HTTP response and creates a specific error struct
  based on the status code and response body structure.
  """
  @spec from_response(map()) :: t()
  def from_response(%{status: 429, body: body}) do
    %RateLimitError{
      retry_after: get_retry_after(body),
      limit: get_rate_limit(body),
      remaining: get_rate_remaining(body)
    }
  end

  def from_response(%{status: status, body: body}) when status in 400..499 do
    case body do
      %{"error" => %{"code" => code, "message" => message}} ->
        %API{
          status: status,
          code: code,
          message: message,
          details: Map.get(body, "details")
        }

      %{"message" => message} ->
        %API{
          status: status,
          message: message,
          details: Map.drop(body, ["message"])
        }

      _ ->
        %HTTP{
          reason: "Bad request",
          status: status,
          body: body
        }
    end
  end

  def from_response(%{status: status, body: body}) when status >= 500 do
    %HTTP{
      reason: "Server error",
      status: status,
      body: body
    }
  end

  def from_response(%{status: status, body: body}) do
    %HTTP{
      reason: "Unexpected status code",
      status: status,
      body: body
    }
  end

  def from_response(error) do
    %HTTP{
      reason: error,
      status: nil,
      body: nil
    }
  end

  defp get_retry_after(body) do
    case body do
      %{"retry_after" => retry_after} when is_integer(retry_after) -> retry_after
      %{"retryAfter" => retry_after} when is_integer(retry_after) -> retry_after
      _ -> nil
    end
  end

  defp get_rate_limit(body) do
    case body do
      %{"rate_limit" => limit} when is_integer(limit) -> limit
      %{"rateLimit" => limit} when is_integer(limit) -> limit
      _ -> nil
    end
  end

  defp get_rate_remaining(body) do
    case body do
      %{"rate_remaining" => remaining} when is_integer(remaining) -> remaining
      %{"rateRemaining" => remaining} when is_integer(remaining) -> remaining
      _ -> nil
    end
  end
end

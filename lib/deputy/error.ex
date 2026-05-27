defmodule Deputy.Error do
  @moduledoc """
  Error types for Deputy API client operations.

  This module provides standardized error structs for different types of errors that can occur
  when interacting with the Deputy API.
  """

  @type t ::
          Deputy.Error.APIError.t()
          | Deputy.Error.HTTPError.t()
          | Deputy.Error.ParseError.t()
          | Deputy.Error.RateLimitError.t()
          | Deputy.Error.ValidationError.t()

  defmodule APIError do
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

  defmodule HTTPError do
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

  ## Examples

      iex> Deputy.Error.from_response(%{status: 404, body: %{"message" => "Not found"}})
      %Deputy.Error.APIError{status: 404, code: nil, message: "Not found", details: %{}}

      iex> Deputy.Error.from_response(%{status: 429, body: %{"retry_after" => 30}})
      %Deputy.Error.RateLimitError{retry_after: 30, limit: nil, remaining: nil}

      iex> Deputy.Error.from_response(%{status: 500, body: "Server error"})
      %Deputy.Error.HTTPError{reason: "Server error", status: 500, body: "Server error"}

      iex> Deputy.Error.from_response(:timeout)
      %Deputy.Error.HTTPError{reason: :timeout, status: nil, body: nil}

  """
  @retry_after_keys ["retry_after", "retryAfter"]
  @rate_limit_keys ["rate_limit", "rateLimit"]
  @rate_remaining_keys ["rate_remaining", "rateRemaining"]

  @spec from_response(map()) :: t()
  def from_response(%{status: 429, body: body} = resp) do
    headers = Map.get(resp, :headers)

    %RateLimitError{
      retry_after: header_int(headers, "retry-after") || body_int(body, @retry_after_keys),
      limit:
        header_int(headers, "x-ratelimit-limit") ||
          header_int(headers, "x-rate-limit-limit") || body_int(body, @rate_limit_keys),
      remaining:
        header_int(headers, "x-ratelimit-remaining") ||
          header_int(headers, "x-rate-limit-remaining") || body_int(body, @rate_remaining_keys)
    }
  end

  def from_response(%{status: status, body: body}) when status in 400..499 do
    case body do
      %{"error" => %{"code" => code, "message" => message}} ->
        %APIError{
          status: status,
          code: code,
          message: message,
          details: Map.get(body, "details")
        }

      %{"message" => message} ->
        %APIError{
          status: status,
          message: message,
          details: Map.drop(body, ["message"])
        }

      _ ->
        %HTTPError{
          reason: "Bad request",
          status: status,
          body: body
        }
    end
  end

  def from_response(%{status: status, body: body}) when status >= 500 do
    %HTTPError{
      reason: "Server error",
      status: status,
      body: body
    }
  end

  def from_response(%{status: status, body: body}) do
    %HTTPError{
      reason: "Unexpected status code",
      status: status,
      body: body
    }
  end

  def from_response(error) do
    %HTTPError{
      reason: error,
      status: nil,
      body: nil
    }
  end

  defp header_int(headers, name) when is_map(headers) do
    headers |> fetch_header(name) |> parse_int()
  end

  defp header_int(headers, name) when is_list(headers) do
    case Enum.find(headers, fn
           {k, _} when is_binary(k) -> String.downcase(k) == name
           _ -> false
         end) do
      {_, v} -> parse_int(v)
      _ -> nil
    end
  end

  defp header_int(_, _), do: nil

  defp fetch_header(headers, name) do
    case Map.get(headers, name) do
      nil -> find_header_value(headers, name)
      v -> v
    end
  end

  defp find_header_value(headers, name) do
    Enum.find_value(headers, fn
      {k, v} when is_binary(k) -> match_header(k, v, name)
      _ -> nil
    end)
  end

  defp match_header(key, value, name) do
    if String.downcase(key) == name, do: value
  end

  defp parse_int([v | _]), do: parse_int(v)

  defp parse_int(v) when is_binary(v) do
    case Integer.parse(v) do
      {n, ""} -> n
      _ -> nil
    end
  end

  defp parse_int(_), do: nil

  defp body_int(body, keys) when is_map(body) do
    Enum.find_value(keys, fn key ->
      case Map.get(body, key) do
        v when is_integer(v) -> v
        _ -> nil
      end
    end)
  end

  defp body_int(_, _), do: nil
end

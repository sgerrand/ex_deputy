defmodule Deputy do
  @moduledoc """
  Deputy is an Elixir client for the Deputy API.

  ## Configuration

  You can configure the Deputy client with:

  ```elixir
  client = Deputy.new(
    base_url: "https://your-subdomain.deputy.com",
    api_key: "your-api-key"
  )
  ```

  ## Usage Example

  ```elixir
  # Create a client
  client = Deputy.new(
    base_url: "https://your-subdomain.deputy.com",
    api_key: "your-api-key"
  )

  # Get locations
  {:ok, locations} = Deputy.Locations.get_locations(client)

  # Error handling
  case Deputy.Locations.get_location(client, 12345) do
    {:ok, location} ->
      # Process location data
      IO.inspect(location)

    {:error, %Deputy.Error.API{status: 404}} ->
      # Handle not found error
      IO.puts("Location not found")

    {:error, %Deputy.Error.HTTP{reason: reason}} ->
      # Handle HTTP error
      IO.puts("HTTP error: " <> inspect(reason))

    {:error, %Deputy.Error.RateLimitError{retry_after: seconds}} ->
      # Handle rate limit
      IO.puts("Rate limited. Try again in " <> to_string(seconds) <> " seconds")
  end
  ```
  """

  alias Deputy.HTTPClient
  alias Deputy.Error

  @type t :: %__MODULE__{
          base_url: String.t(),
          api_key: String.t(),
          http_client: module()
        }

  defstruct [:base_url, :api_key, :http_client]

  @doc """
  Creates a new Deputy client with the given configuration.

  ## Options

  * `:base_url` - Required. The base URL for the Deputy API.
  * `:api_key` - Required. The API key for authentication.
  * `:http_client` - Optional. Module implementing the HTTPClient behavior. Defaults to Deputy.HTTPClient.Req.

  ## Examples

      iex> Deputy.new(base_url: "https://your-subdomain.deputy.com", api_key: "your-api-key")
      %Deputy{base_url: "https://your-subdomain.deputy.com", api_key: "your-api-key", http_client: Deputy.HTTPClient.Req}

  """
  @spec new(Keyword.t()) :: t()
  def new(opts) do
    base_url = Keyword.fetch!(opts, :base_url)
    api_key = Keyword.fetch!(opts, :api_key)
    http_client = Keyword.get(opts, :http_client, HTTPClient.Req)

    %__MODULE__{
      base_url: base_url,
      api_key: api_key,
      http_client: http_client
    }
  end

  @doc """
  Makes a HTTP request to the Deputy API.

  This is used internally by the API module functions.

  ## Returns

  * `{:ok, response_body}` - Successful API call with response body
  * `{:error, error}` - Error from an API call where `error` is one of:
    * `%Deputy.Error.API{}` - API error with details from Deputy
    * `%Deputy.Error.HTTP{}` - HTTP transport-level error
    * `%Deputy.Error.RateLimitError{}` - Rate limit exceeded
    * `%Deputy.Error.ParseError{}` - Failed to parse response
    * `%Deputy.Error.ValidationError{}` - Validation of request parameters failed
  """
  @spec request(t(), atom(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def request(%__MODULE__{} = client, method, path, opts \\ []) do
    url = client.base_url <> path

    headers = [
      {"Authorization", "Bearer #{client.api_key}"}
    ]

    request_opts = [
      method: method,
      url: url,
      headers: headers
    ]

    # Validate required parameters if provided
    with {:ok, request_opts} <- validate_and_add_body(request_opts, opts),
         {:ok, request_opts} <- validate_and_add_params(request_opts, opts) do
      client.http_client.request(request_opts)
    end
  end

  @doc """
  Makes a HTTP request to the Deputy API.

  Raises an exception if the API call returns an error.

  ## Examples

      # client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      # locations = Deputy.request!(client, :get, "/api/v1/resource/Company")
  """
  @spec request!(t(), atom(), String.t(), keyword()) :: map()
  def request!(client, method, path, opts \\ []) do
    case request(client, method, path, opts) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  defp validate_and_add_body(request_opts, opts) do
    case Keyword.get(opts, :body) do
      nil ->
        {:ok, request_opts}

      body when is_map(body) or is_list(body) ->
        {:ok, Keyword.put(request_opts, :json, body)}

      _invalid ->
        {:error,
         %Error.ValidationError{
           message: "Request body must be a map or list",
           field: :body,
           value: Keyword.get(opts, :body)
         }}
    end
  end

  defp validate_and_add_params(request_opts, opts) do
    case Keyword.get(opts, :params) do
      nil ->
        {:ok, request_opts}

      params when is_map(params) or is_list(params) ->
        {:ok, Keyword.put(request_opts, :params, params)}

      _invalid ->
        {:error,
         %Error.ValidationError{
           message: "Request params must be a map or list",
           field: :params,
           value: Keyword.get(opts, :params)
         }}
    end
  end
end

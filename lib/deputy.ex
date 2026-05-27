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

    {:error, %Deputy.Error.APIError{status: 404}} ->
      # Handle not found error
      IO.puts("Location not found")

    {:error, %Deputy.Error.HTTPError{reason: reason}} ->
      # Handle HTTP error
      IO.puts("HTTP error: " <> inspect(reason))

    {:error, %Deputy.Error.RateLimitError{retry_after: seconds}} ->
      # Handle rate limit
      IO.puts("Rate limited. Try again in " <> to_string(seconds) <> " seconds")
  end
  ```

  ## Telemetry

  Deputy emits the following `:telemetry` events for every API request made via `Deputy.HTTPClient.Req`:

  ### `[:deputy, :request, :start]`

  Emitted before the HTTP request is sent.

  | measurements | type | description |
  |---|---|---|
  | `system_time` | `integer` | Current system time in native units (`System.system_time/0`) |

  | metadata | type | description |
  |---|---|---|
  | `method` | `atom` | HTTP method (e.g. `:get`, `:post`) |
  | `url` | `String.t()` | Full request URL |

  ### `[:deputy, :request, :stop]`

  Emitted after the HTTP response is received and classified.

  | measurements | type | description |
  |---|---|---|
  | `duration` | `integer` | Elapsed time in native units (use `System.convert_time_unit/3` to convert) |

  | metadata | type | description |
  |---|---|---|
  | `method` | `atom` | HTTP method |
  | `url` | `String.t()` | Full request URL |
  | `status` | `atom \| integer` | `:ok` for 2xx responses, HTTP status integer for API errors, `:error` for transport errors |

  ### `[:deputy, :request, :exception]`

  Emitted when the underlying HTTP call raises, throws, or exits before a
  response can be classified. The exception is re-raised after the event
  is dispatched, so handlers do not swallow failures. No `:stop` event is
  emitted for the same request when `:exception` fires.

  | measurements | type | description |
  |---|---|---|
  | `duration` | `integer` | Elapsed time in native units before the failure |

  | metadata | type | description |
  |---|---|---|
  | `method` | `atom` | HTTP method |
  | `url` | `String.t()` | Full request URL |
  | `kind` | `:error \| :exit \| :throw` | Kind of failure, matching `Kernel.SpecialForms` semantics |
  | `reason` | `Exception.t() \| term()` | Exception struct (for `:error`) or raw value (for `:throw`/`:exit`) |
  | `stacktrace` | `list` | Stacktrace captured at the failure site |
  """

  alias Deputy.Error
  alias Deputy.HTTPClient
  alias Deputy.HTTPClient.Request

  @type auth_scheme :: :bearer | :oauth | :dpauth

  @type t :: %__MODULE__{
          base_url: String.t(),
          api_key: String.t(),
          http_client: module(),
          auth_scheme: auth_scheme()
        }

  defstruct [:base_url, :api_key, :http_client, :auth_scheme]

  @valid_auth_schemes [:bearer, :oauth, :dpauth]

  @doc """
  Creates a new Deputy client with the given configuration.

  ## Options

  * `:base_url` - Required. The base URL for the Deputy API.
  * `:api_key` - Required. The API key for authentication.
  * `:http_client` - Optional. Module implementing the HTTPClient behavior. Defaults to Deputy.HTTPClient.Req.
  * `:auth_scheme` - Optional. How the API key is sent. One of:
    * `:bearer` (default) - `Authorization: Bearer <key>`. Use for OAuth 2.0 access tokens.
    * `:oauth` - `Authorization: OAuth <key>`. Use for legacy OAuth tokens.
    * `:dpauth` - `dpauth: <key>` header. Use for Deputy permanent tokens.

  ## Examples

      iex> Deputy.new(base_url: "https://your-subdomain.deputy.com", api_key: "your-api-key")
      %Deputy{base_url: "https://your-subdomain.deputy.com", api_key: "your-api-key", http_client: Deputy.HTTPClient.Req, auth_scheme: :bearer}

      iex> Deputy.new(base_url: "https://your-subdomain.deputy.com", api_key: "permanent-token", auth_scheme: :dpauth)
      %Deputy{base_url: "https://your-subdomain.deputy.com", api_key: "permanent-token", http_client: Deputy.HTTPClient.Req, auth_scheme: :dpauth}

  """
  @spec new(Keyword.t()) :: t()
  def new(opts) do
    base_url = Keyword.fetch!(opts, :base_url)
    api_key = Keyword.fetch!(opts, :api_key)
    http_client = Keyword.get(opts, :http_client, HTTPClient.Req)
    auth_scheme = Keyword.get(opts, :auth_scheme, :bearer)

    unless auth_scheme in @valid_auth_schemes do
      raise ArgumentError,
            "invalid :auth_scheme #{inspect(auth_scheme)}, expected one of #{inspect(@valid_auth_schemes)}"
    end

    %__MODULE__{
      base_url: base_url,
      api_key: api_key,
      http_client: http_client,
      auth_scheme: auth_scheme
    }
  end

  @doc """
  Makes a HTTP request to the Deputy API.

  This is used internally by the API module functions.

  ## Options

  * `:body` - Request body, must be a map or list. Encoded as JSON.
  * `:params` - URL query parameters, must be a map or keyword list.
  * `:retry` - Retry strategy forwarded to the underlying HTTP client.
    With the default `Deputy.HTTPClient.Req` adapter this maps directly
    to `Req`'s `:retry` option. Common values:
    * `:safe_transient` (recommended) - retry idempotent methods on
      transient network errors and HTTP 408/429/500/502/503/504.
    * `:transient` - same as `:safe_transient` but also retries
      non-idempotent methods. Use with caution; may cause duplicate
      writes for POST requests.
    * `false` - disable retries (default behaviour when option absent).
    * A function `(req, resp_or_err) -> boolean | {:delay, ms}`.

    `Req` honours the `Retry-After` header automatically.

  ## Returns

  * `{:ok, response_body}` - Successful API call with response body
  * `{:error, error}` - Error from an API call where `error` is one of:
    * `%Deputy.Error.APIError{}` - API error with details from Deputy
    * `%Deputy.Error.HTTPError{}` - HTTP transport-level error
    * `%Deputy.Error.RateLimitError{}` - Rate limit exceeded
    * `%Deputy.Error.ParseError{}` - Failed to parse response
    * `%Deputy.Error.ValidationError{}` - Validation of request parameters failed
  """
  @spec request(t(), atom(), String.t(), keyword()) :: {:ok, map() | list()} | {:error, Error.t()}
  def request(%__MODULE__{} = client, method, path, opts \\ []) do
    request = %Request{
      method: method,
      url: client.base_url <> path,
      headers: auth_headers(client),
      retry: Keyword.get(opts, :retry)
    }

    with {:ok, request} <- put_body(request, opts),
         {:ok, request} <- put_params(request, opts) do
      client.http_client.request(request)
    end
  end

  @doc """
  Makes a HTTP request to the Deputy API.

  Raises an exception if the API call returns an error.

  ## Examples

      # client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      # locations = Deputy.request!(client, :get, "/api/v1/resource/Company")
  """
  @spec request!(t(), atom(), String.t(), keyword()) :: map() | list()
  def request!(client, method, path, opts \\ []) do
    client |> request(method, path, opts) |> unwrap!()
  end

  @doc """
  Unwraps an `{:ok, value} | {:error, error}` tuple, returning the value on
  success or raising the error on failure.

  Used by resource bang functions to share the unwrap path with the
  validated, non-bang variant so request paths cannot drift.
  """
  @spec unwrap!({:ok, value} | {:error, Exception.t()}) :: value when value: term()
  def unwrap!({:ok, value}), do: value
  def unwrap!({:error, error}), do: raise(error)

  defp auth_headers(%__MODULE__{auth_scheme: :bearer, api_key: key}),
    do: [{"Authorization", "Bearer #{key}"}]

  defp auth_headers(%__MODULE__{auth_scheme: :oauth, api_key: key}),
    do: [{"Authorization", "OAuth #{key}"}]

  defp auth_headers(%__MODULE__{auth_scheme: :dpauth, api_key: key}),
    do: [{"dpauth", key}]

  defp put_body(request, opts) do
    case Keyword.get(opts, :body) do
      nil ->
        {:ok, request}

      body when is_map(body) or is_list(body) ->
        {:ok, %{request | body: body}}

      _invalid ->
        {:error,
         %Error.ValidationError{
           message: "Request body must be a map or list",
           field: :body,
           value: Keyword.get(opts, :body)
         }}
    end
  end

  defp put_params(request, opts) do
    case Keyword.get(opts, :params) do
      nil ->
        {:ok, request}

      params when is_map(params) or is_list(params) ->
        {:ok, %{request | params: params}}

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

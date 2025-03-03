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
  ```
  """

  alias Deputy.HTTPClient

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
  """
  @spec request(t(), atom(), String.t(), keyword()) :: {:ok, map()} | {:error, any()}
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

    # Add body if it exists
    request_opts =
      case Keyword.get(opts, :body) do
        nil -> request_opts
        body -> Keyword.put(request_opts, :json, body)
      end

    # Add query params if they exist
    request_opts =
      case Keyword.get(opts, :params) do
        nil -> request_opts
        params -> Keyword.put(request_opts, :params, params)
      end

    client.http_client.request(request_opts)
  end
end

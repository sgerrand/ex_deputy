defmodule Deputy.Sales do
  @moduledoc """
  Functions for interacting with sales metrics in Deputy.
  """

  @doc """
  Add a sale to sales metrics.

  ## Parameters

  - `client`: A Deputy client.
  - `metrics`: A map containing sales data.

  ## Metrics parameters

  - `data`: Array of sale objects with the following fields:
    - `timestamp`: Unix timestamp of the sale.
    - `area`: ID of the area where the sale occurred.
    - `type`: Type of metric (e.g., "Sales").
    - `reference`: Reference ID for the sale.
    - `value`: Sale amount.
    - `employee`: Optional. ID of the employee who made the sale.
    - `location`: ID of the location where the sale occurred.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      metrics = %{
        data: [
          %{
            timestamp: 1660272300,
            area: 2,
            type: "Sales",
            reference: "API-Sales-Entry-1660272300",
            value: 100.30,
            employee: 1,
            location: 1
          }
        ]
      }
      Deputy.Sales.add_metrics(client, metrics)
      # => {:ok, %{"success" => true}}

  """
  @spec add_metrics(Deputy.t(), map()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def add_metrics(client, metrics) do
    Deputy.request(client, :post, "/api/v2/metrics", body: metrics)
  end

  @doc """
  Retrieve sales data.

  ## Parameters

  - `client`: A Deputy client.
  - `params`: A map (or keyword list) of query parameters.

  ## Query parameters

  Every value must be a `String.t()` — the Deputy API rejects requests
  where numeric IDs or timestamps are sent as JSON numbers rather than
  serialised strings.

  - `areas` (`String.t()`): Comma-separated list of area IDs, e.g. `"1,2,3"`.
  - `types` (`String.t()`): Comma-separated list of metric types, e.g. `"Sales"` or `"Sales,Footfall"`.
  - `start` (`String.t()`): Unix timestamp for the inclusive start of the window, e.g. `"1626203567"`.
  - `end` (`String.t()`): Unix timestamp for the inclusive end of the window, e.g. `"1657775576"`.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      params = %{
        areas: "1",
        types: "Sales",
        start: "1626203567",
        end: "1657775576"
      }
      Deputy.Sales.get_metrics(client, params)
      # => {:ok, [%{"timestamp" => 1626203600, "area" => 1, "type" => "Sales", "value" => 100.30}]}

  """
  @spec get_metrics(Deputy.t(), %{optional(atom() | String.t()) => String.t()} | keyword()) ::
          {:ok, list(map())} | {:error, Deputy.Error.t()}
  def get_metrics(client, params) do
    Deputy.request(client, :get, "/api/v2/metrics/raw", params: params)
  end

  @doc "Same as `add_metrics/2` but raises on error."
  @spec add_metrics!(Deputy.t(), map()) :: map()
  def add_metrics!(client, metrics), do: client |> add_metrics(metrics) |> Deputy.unwrap!()

  @doc "Same as `get_metrics/2` but raises on error."
  @spec get_metrics!(Deputy.t(), map()) :: list(map())
  def get_metrics!(client, params), do: client |> get_metrics(params) |> Deputy.unwrap!()
end

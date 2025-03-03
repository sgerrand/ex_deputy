defmodule Deputy.Sales do
  @moduledoc """
  Functions for interacting with sales metrics in Deputy.
  """

  alias Deputy

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

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> metrics = %{
      ...>   data: [
      ...>     %{
      ...>       timestamp: 1660272300,
      ...>       area: 2,
      ...>       type: "Sales",
      ...>       reference: "API-Sales-Entry-1660272300",
      ...>       value: 100.30,
      ...>       employee: 1,
      ...>       location: 1
      ...>     }
      ...>   ]
      ...> }
      iex> Deputy.Sales.add_metrics(client, metrics)
      {:ok, %{"success" => true}}

  """
  @spec add_metrics(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def add_metrics(client, metrics) do
    Deputy.request(client, :post, "/api/v2/metrics", body: metrics)
  end

  @doc """
  Retrieve sales data.

  ## Parameters

  - `client`: A Deputy client.
  - `params`: A map containing query parameters.

  ## Query parameters

  - `areas`: Comma-separated list of area IDs.
  - `types`: Comma-separated list of metric types (e.g., "Sales").
  - `start`: Unix timestamp for the start date.
  - `end`: Unix timestamp for the end date.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> params = %{
      ...>   areas: "1",
      ...>   types: "Sales",
      ...>   start: "1626203567",
      ...>   end: "1657775576"
      ...> }
      iex> Deputy.Sales.get_metrics(client, params)
      {:ok, [%{"timestamp" => 1626203600, "area" => 1, "type" => "Sales", "value" => 100.30}]}

  """
  @spec get_metrics(Deputy.t(), map()) :: {:ok, list(map())} | {:error, any()}
  def get_metrics(client, params) do
    Deputy.request(client, :get, "/api/v2/metrics/raw", params: params)
  end
end

defmodule Deputy.Rosters do
  @moduledoc """
  Functions for interacting with rosters in Deputy.
  """

  alias Deputy

  @doc """
  Get a list of rosters from the last 12 hours and forward 36 hours.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Rosters.list(client)
      {:ok, [%{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}]}

  """
  @spec list(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def list(client) do
    Deputy.request(client, :get, "/api/v1/supervise/roster")
  end

  @doc """
  Get a specific roster by ID.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the roster to retrieve.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Rosters.get(client, 1)
      {:ok, %{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}}

  """
  @spec get(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def get(client, id) do
    Deputy.request(client, :get, "/api/v1/supervise/roster/#{id}")
  end

  @doc """
  Get rosters for a specific date.

  ## Parameters

  - `client`: A Deputy client.
  - `date`: The date to retrieve rosters for, in format "YYYY-MM-DD".

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Rosters.get_by_date(client, "2023-01-01")
      {:ok, [%{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}]}

  """
  @spec get_by_date(Deputy.t(), String.t()) :: {:ok, list(map())} | {:error, any()}
  def get_by_date(client, date) do
    params = %{date: date}
    Deputy.request(client, :get, "/api/v1/supervise/roster", params: params)
  end

  @doc """
  Get rosters for a specific date and location.

  ## Parameters

  - `client`: A Deputy client.
  - `date`: The date to retrieve rosters for, in format "YYYY-MM-DD".
  - `location_id`: The ID of the location.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Rosters.get_by_date_and_location(client, "2023-01-01", 1)
      {:ok, [%{"Id" => 1, "StartTime" => "2023-01-01T09:00:00", "CompanyId" => 1}]}

  """
  @spec get_by_date_and_location(Deputy.t(), String.t(), integer()) ::
          {:ok, list(map())} | {:error, any()}
  def get_by_date_and_location(client, date, location_id) do
    params = %{date: date, intCompanyId: location_id}
    Deputy.request(client, :get, "/api/v1/supervise/roster", params: params)
  end

  @doc """
  Copy rosters from one date range to another.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the copy parameters.

  ## Copy parameters

  - `strFromDate`: Start date of the source rosters in format "YYYY-MM-DD".
  - `strToDate`: Start date for the destination rosters in format "YYYY-MM-DD".
  - `intOperationalUnitArray`: Array of operational unit IDs to copy rosters for.
  - `blnRequireErrorDetails`: Optional. Whether to return detailed error information (1 for true, 0 for false).

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   strFromDate: "2023-01-01",
      ...>   strToDate: "2023-01-08",
      ...>   intOperationalUnitArray: [1, 2],
      ...>   blnRequireErrorDetails: 1
      ...> }
      iex> Deputy.Rosters.copy(client, attrs)
      {:ok, %{"success" => true}}

  """
  @spec copy(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def copy(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/roster/copy", body: attrs)
  end

  @doc """
  Publish rosters.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the publish parameters.

  ## Publish parameters

  - `intMode`: Mode for publishing (e.g., 1).
  - `blnAllLocationsMode`: Whether to publish for all locations (1 for true, 0 for false).
  - `intRosterArray`: Array of roster IDs to publish.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   intMode: 1,
      ...>   blnAllLocationsMode: 1,
      ...>   intRosterArray: [400]
      ...> }
      iex> Deputy.Rosters.publish(client, attrs)
      {:ok, %{"success" => true}}

  """
  @spec publish(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def publish(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/roster/publish", body: attrs)
  end

  @doc """
  Create a new roster.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the roster details.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   intEmployeeId: 1,
      ...>   intOperationalUnitId: 2,
      ...>   intCompanyId: 3,
      ...>   dtmStartTime: "2023-01-01 09:00:00",
      ...>   dtmEndTime: "2023-01-01 17:00:00"
      ...> }
      iex> Deputy.Rosters.create(client, attrs)
      {:ok, %{"Id" => 123}}

  """
  @spec create(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def create(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/roster/create", body: attrs)
  end

  @doc """
  Discard rosters.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the discard parameters.

  ## Discard parameters

  - `intRosterArray`: Array of roster IDs to discard.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{intRosterArray: [400]}
      iex> Deputy.Rosters.discard(client, attrs)
      {:ok, %{"success" => true}}

  """
  @spec discard(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def discard(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/roster/discard", body: attrs)
  end

  @doc """
  Get rosters available for swap.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Rosters.get_available_for_swap(client)
      {:ok, [%{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}]}

  """
  @spec get_available_for_swap(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def get_available_for_swap(client) do
    Deputy.request(client, :get, "/api/v1/supervise/roster/autobuild")
  end

  @doc """
  Get recommendations for a roster.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the roster to get recommendations for.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Rosters.get_recommendations(client, 1)
      {:ok, [%{"EmployeeId" => 123, "Score" => 85}]}

  """
  @spec get_recommendations(Deputy.t(), integer()) :: {:ok, list(map())} | {:error, any()}
  def get_recommendations(client, id) do
    Deputy.request(client, :get, "/api/v1/supervise/getRecommendation/#{id}")
  end
end

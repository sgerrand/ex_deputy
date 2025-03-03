defmodule Deputy.Timesheets do
  @moduledoc """
  Functions for interacting with timesheets in Deputy.
  """

  alias Deputy

  @doc """
  Start an employee's timesheet (clock on).

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the timesheet details.

  ## Timesheet parameters

  - `intEmployeeId`: ID of the employee.
  - `intCompanyId`: ID of the company/location.
  - `intOperationalUnitId`: Optional. ID of the operational unit.
  - `intRosterId`: Optional. ID of the roster.
  - `startTime`: Optional. Start time in format "YYYY-MM-DD HH:MM:SS".

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   intEmployeeId: 123,
      ...>   intCompanyId: 456
      ...> }
      iex> Deputy.Timesheets.start(client, attrs)
      {:ok, %{"Id" => 789}}

  """
  @spec start(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def start(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/timesheet/start", body: attrs)
  end

  @doc """
  Stop an employee's timesheet (clock off).

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the timesheet details.

  ## Timesheet parameters

  - `intTimesheetId`: ID of the timesheet to stop.
  - `intMealbreakMinute`: Optional. Duration of meal break in minutes.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   intTimesheetId: 123,
      ...>   intMealbreakMinute: 30
      ...> }
      iex> Deputy.Timesheets.stop(client, attrs)
      {:ok, %{"success" => true}}

  """
  @spec stop(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def stop(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/timesheet/end", body: attrs)
  end

  @doc """
  Pause or unpause an employee's timesheet (take a break/finish break).

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the timesheet details.

  ## Timesheet parameters

  - `intTimesheetId`: ID of the timesheet to pause/unpause.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{intTimesheetId: 123}
      iex> Deputy.Timesheets.pause(client, attrs)
      {:ok, %{"success" => true}}

  """
  @spec pause(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def pause(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/timesheet/pause", body: attrs)
  end

  @doc """
  View timesheet details by ID.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the timesheet to retrieve.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Timesheets.get_details(client, 123)
      {:ok, %{"Id" => 123, "StartTime" => "2023-01-01T09:00:00"}}

  """
  @spec get_details(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def get_details(client, id) do
    Deputy.request(client, :get, "/api/v1/supervise/timesheet/#{id}/details")
  end

  @doc """
  Search for timesheets using the resource API.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: Optional. The ID of a specific timesheet to retrieve.
  - `query`: Optional. A map containing search criteria.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> query = %{
      ...>   search: %{id: %{field: "Id", type: "eq", data: 1}},
      ...>   join: ["TimesheetObject"]
      ...> }
      iex> Deputy.Timesheets.query(client, nil, query)
      {:ok, [%{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}]}

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Timesheets.query(client, 1, nil)
      {:ok, %{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}}

  """
  @spec query(Deputy.t(), integer() | nil, map() | nil) ::
          {:ok, map() | list(map())} | {:error, any()}
  def query(client, id, query \\ nil)

  def query(client, id, nil) when is_integer(id) do
    Deputy.request(client, :get, "/api/v1/resource/Timesheet/#{id}")
  end

  def query(client, nil, query) when is_map(query) do
    Deputy.request(client, :post, "/api/v1/resource/Timesheet/QUERY", body: query)
  end

  def query(client, id, query) when is_integer(id) and is_map(query) do
    Deputy.request(client, :post, "/api/v1/resource/Timesheet/#{id}", body: query)
  end
end

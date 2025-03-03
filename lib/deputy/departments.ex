defmodule Deputy.Departments do
  @moduledoc """
  Functions for interacting with departments (operational units) in Deputy.
  """

  alias Deputy

  @doc """
  Create a department (operational unit).

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the new department details.

  ## Department parameters

  - `intCompanyId`: ID of the company/location.
  - `strOpunitName`: Name of the department.
  - `strAddress`: Address of the department.
  - `strExportName`: Optional. Name to use for exports.
  - `intSortOrder`: Optional. Sort order.
  - `intOpunitType`: Type of operational unit.
  - `LocationId`: Optional. ID of the location.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   intCompanyId: 1,
      ...>   strOpunitName: "Sales",
      ...>   strAddress: "123 Main St",
      ...>   intOpunitType: 1
      ...> }
      iex> Deputy.Departments.create(client, attrs)
      {:ok, %{"Id" => 123}}

  """
  @spec create(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def create(client, attrs) do
    Deputy.request(client, :put, "/api/v1/supervise/department", body: attrs)
  end

  @doc """
  Create multiple departments.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the array of departments to create.

  ## Parameters

  - `arrArea`: Array of department objects.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   arrArea: [
      ...>     %{
      ...>       intCompanyId: 1,
      ...>       strOpunitName: "Sales",
      ...>       strAddress: "123 Main St",
      ...>       intOpunitType: 1
      ...>     },
      ...>     %{
      ...>       intCompanyId: 1,
      ...>       strOpunitName: "Marketing",
      ...>       strAddress: "123 Main St",
      ...>       intOpunitType: 1
      ...>     }
      ...>   ]
      ...> }
      iex> Deputy.Departments.create_multiple(client, attrs)
      {:ok, %{"success" => true}}

  """
  @spec create_multiple(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def create_multiple(client, attrs) do
    Deputy.request(client, :put, "/api/v1/supervise/department/create/", body: attrs)
  end

  @doc """
  Get all operational units (departments).

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Departments.list(client)
      {:ok, [%{"Id" => 1, "OpunitName" => "Sales"}]}

  """
  @spec list(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def list(client) do
    Deputy.request(client, :get, "/api/v1/resource/OperationalUnit/")
  end

  @doc """
  Delete an operational unit (department).

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the department to delete.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Departments.delete(client, 1)
      {:ok, %{"success" => true}}

  """
  @spec delete(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def delete(client, id) do
    Deputy.request(client, :delete, "/api/v1/resource/OperationalUnit/#{id}")
  end

  @doc """
  Update an operational unit (department).

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the department to update.
  - `attrs`: A map containing the fields to update.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   intCompanyId: 12,
      ...>   strOpunitName: "Updated Department Name"
      ...> }
      iex> Deputy.Departments.update(client, 20, attrs)
      {:ok, %{"success" => true}}

  """
  @spec update(Deputy.t(), integer(), map()) :: {:ok, map()} | {:error, any()}
  def update(client, id, attrs) do
    Deputy.request(client, :post, "/api/v1/resource/OperationalUnit/#{id}", body: attrs)
  end

  @doc """
  Retrieve preferred employees for a specific area/department.

  ## Parameters

  - `client`: A Deputy client.
  - `query`: A map containing the search query.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> query = %{
      ...>   join: [],
      ...>   assoc: ["RosterEmployeeOperationalUnit"],
      ...>   search: %{id: %{field: "Id", type: "eq", data: 1}}
      ...> }
      iex> Deputy.Departments.query(client, query)
      {:ok, [%{"Id" => 1, "Employees" => [%{"Id" => 123, "FirstName" => "John"}]}]}

  """
  @spec query(Deputy.t(), map()) :: {:ok, list(map())} | {:error, any()}
  def query(client, query) do
    Deputy.request(client, :post, "/api/v1/resource/OperationalUnit/QUERY", body: query)
  end
end

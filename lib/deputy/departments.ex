defmodule Deputy.Departments do
  @moduledoc """
  Functions for interacting with departments (operational units) in Deputy.
  """

  alias Deputy
  alias Deputy.Error.ValidationError

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
  @spec create(Deputy.t(), map()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def create(client, attrs) do
    required = [:intCompanyId, :strOpunitName]

    with :ok <- validate_required_fields(attrs, required) do
      Deputy.request(client, :put, "/api/v1/supervise/department", body: attrs)
    end
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
  @spec create_multiple(Deputy.t(), map()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def create_multiple(client, attrs) do
    with :ok <- validate_required_fields(attrs, [:arrArea]) do
      Deputy.request(client, :put, "/api/v1/supervise/department/create/", body: attrs)
    end
  end

  @doc """
  Get all operational units (departments).

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Departments.list(client)
      {:ok, [%{"Id" => 1, "OpunitName" => "Sales"}]}

  """
  @spec list(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
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
  @spec delete(Deputy.t(), integer()) :: {:ok, map()} | {:error, Deputy.Error.t()}
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
  @spec update(Deputy.t(), integer(), map()) :: {:ok, map()} | {:error, Deputy.Error.t()}
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
  @spec query(Deputy.t(), map()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def query(client, query) do
    Deputy.request(client, :post, "/api/v1/resource/OperationalUnit/QUERY", body: query)
  end

  @doc "Same as `create/2` but raises on error."
  @spec create!(Deputy.t(), map()) :: map()
  def create!(client, attrs),
    do: Deputy.request!(client, :put, "/api/v1/supervise/department", body: attrs)

  @doc "Same as `create_multiple/2` but raises on error."
  @spec create_multiple!(Deputy.t(), map()) :: map()
  def create_multiple!(client, attrs),
    do: Deputy.request!(client, :put, "/api/v1/supervise/department/create/", body: attrs)

  @doc "Same as `list/1` but raises on error."
  @spec list!(Deputy.t()) :: list(map())
  def list!(client), do: Deputy.request!(client, :get, "/api/v1/resource/OperationalUnit/")

  @doc "Same as `delete/2` but raises on error."
  @spec delete!(Deputy.t(), integer()) :: map()
  def delete!(client, id),
    do: Deputy.request!(client, :delete, "/api/v1/resource/OperationalUnit/#{id}")

  @doc "Same as `update/3` but raises on error."
  @spec update!(Deputy.t(), integer(), map()) :: map()
  def update!(client, id, attrs),
    do: Deputy.request!(client, :post, "/api/v1/resource/OperationalUnit/#{id}", body: attrs)

  @doc "Same as `query/2` but raises on error."
  @spec query!(Deputy.t(), map()) :: list(map())
  def query!(client, query),
    do: Deputy.request!(client, :post, "/api/v1/resource/OperationalUnit/QUERY", body: query)

  defp validate_required_fields(attrs, required_fields) do
    missing =
      Enum.filter(required_fields, fn field ->
        not Map.has_key?(attrs, field) and not Map.has_key?(attrs, to_string(field))
      end)

    case missing do
      [] ->
        :ok

      [field | _] ->
        {:error,
         %ValidationError{
           message: "missing required field: #{field}",
           field: field,
           value: nil
         }}
    end
  end
end

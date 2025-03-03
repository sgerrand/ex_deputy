defmodule Deputy.Locations do
  @moduledoc """
  Functions for interacting with locations (companies) in Deputy.
  """

  alias Deputy

  @doc """
  Get all locations.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Locations.list(client)
      {:ok, [%{"Id" => 1, "CompanyName" => "Test Company"}]}

  """
  @spec list(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def list(client) do
    Deputy.request(client, :get, "/api/v1/resource/Company")
  end

  @doc """
  Get a simplified list of locations.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Locations.list_simplified(client)
      {:ok, [%{"Id" => 1, "CompanyName" => "Test Company"}]}

  """
  @spec list_simplified(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def list_simplified(client) do
    Deputy.request(client, :get, "/api/v1/supervise/company/simple")
  end

  @doc """
  Get a location's settings.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the location to retrieve settings for.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Locations.get_settings(client, 1)
      {:ok, %{"WEEK_START" => 1}}

  """
  @spec get_settings(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def get_settings(client, id) do
    Deputy.request(client, :get, "/api/v1/supervise/company/#{id}/settings")
  end

  @doc """
  Modify settings for all locations.

  ## Parameters

  - `client`: A Deputy client.
  - `settings`: A map of settings to update.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Locations.update_all_settings(client, %{"WEEK_START" => 2})
      {:ok, %{"success" => true}}

  """
  @spec update_all_settings(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def update_all_settings(client, settings) do
    Deputy.request(client, :post, "/api/v1/supervise/company/all/settings", body: settings)
  end

  @doc """
  Modify settings for a single location.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the location to update settings for.
  - `settings`: A map of settings to update.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Locations.update_settings(client, 1, %{"WEEK_START" => 2})
      {:ok, %{"success" => true}}

  """
  @spec update_settings(Deputy.t(), integer(), map()) :: {:ok, map()} | {:error, any()}
  def update_settings(client, id, settings) do
    Deputy.request(client, :post, "/api/v1/supervise/company/#{id}/settings", body: settings)
  end

  @doc """
  Archive a location.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the location to archive.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Locations.archive(client, 1)
      {:ok, %{"success" => true}}

  """
  @spec archive(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def archive(client, id) do
    Deputy.request(client, :post, "/api/v1/supervise/company/#{id}/archive")
  end

  @doc """
  Delete a location.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the location to delete.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Locations.delete(client, 1)
      {:ok, %{"success" => true}}

  """
  @spec delete(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def delete(client, id) do
    Deputy.request(client, :post, "/api/v1/supervise/company/#{id}/delete")
  end

  @doc """
  Add a new location.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the new location details.

  ## Location parameters

  - `strWorkplaceName`: String naming the workplace.
  - `strWorkplaceCode`: A string with a length of 3 allowing you to define a short code for the location.
  - `strAddress`: String of the location's address.
  - `strAddressNotes`: Optional. Notes about the address.
  - `intParentCompany`: Optional. Integer ID of parent company.
  - `intIsWorkplace`: Boolean (1 - True, 0 - False) whether the location is considered a workplace.
  - `intIsPayrollEntity`: Boolean (1 - True, 0 - False) whether the location has payroll setup.
  - `strTimezone`: Timezone for the workplace using TZ database naming.
  - `strPayrollExportCode`: Optional. String naming what to use as a code for payroll exports.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   strWorkplaceName: "New Location",
      ...>   strWorkplaceCode: "NLC",
      ...>   strAddress: "123 Test St",
      ...>   intIsWorkplace: 1,
      ...>   intIsPayrollEntity: 1,
      ...>   strTimezone: "America/New_York"
      ...> }
      iex> Deputy.Locations.create(client, attrs)
      {:ok, %{"Id" => 123}}

  """
  @spec create(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def create(client, attrs) do
    Deputy.request(client, :put, "/api/v1/resource/Company", body: attrs)
  end

  @doc """
  Update a location.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the location to update.
  - `attrs`: A map containing the fields to update.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Locations.update(client, 1, %{strWorkplaceCode: "UPD"})
      {:ok, %{"success" => true}}

  """
  @spec update(Deputy.t(), integer(), map()) :: {:ok, map()} | {:error, any()}
  def update(client, id, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/company/#{id}", body: attrs)
  end

  @doc """
  Add a new workplace with areas.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the new workplace details.

  ## Workplace parameters

  - `strWorkplaceName`: String naming the workplace.
  - `strWorkplaceTimezone`: Timezone for the workplace using TZ database naming.
  - `strAddress`: String of the location's address.
  - `strLat`: The latitude of the location using a string.
  - `strLon`: The longitude of the location using a string.
  - `intCountry`: An integer which defines which country the location is in.
  - `arrAreaNames`: An array of the area names to add to the location.
  - `strWorkplaceCode`: A string with a length of 3 allowing you to define a short code for the location.
  - `strPayrollExportCode`: Optional. String naming what to use as a code for payroll exports.
  - `blnIsWorkplace`: Boolean (1 - True, 0 - False) whether the location is considered a workplace.
  - `blnIsPayrollEntity`: Boolean (1 - True, 0 - False) whether the location has payroll setup.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   strWorkplaceName: "New Workplace",
      ...>   strWorkplaceTimezone: "America/New_York",
      ...>   strAddress: "123 Test St",
      ...>   strLat: "40.7128",
      ...>   strLon: "-74.0060",
      ...>   intCountry: 1,
      ...>   arrAreaNames: ["Reception", "Kitchen"],
      ...>   strWorkplaceCode: "NWP",
      ...>   blnIsWorkplace: 1,
      ...>   blnIsPayrollEntity: 1
      ...> }
      iex> Deputy.Locations.create_workplace(client, attrs)
      {:ok, %{"Id" => 123}}

  """
  @spec create_workplace(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def create_workplace(client, attrs) do
    Deputy.request(client, :post, "/api/v1/my/setup/addNewWorkplace", body: attrs)
  end

  @doc """
  Get location by ID.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the location to retrieve.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Locations.get(client, 1)
      {:ok, %{"Id" => 1, "CompanyName" => "Test Company"}}

  """
  @spec get(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def get(client, id) do
    Deputy.request(client, :get, "/api/v1/my/location/#{id}")
  end
end

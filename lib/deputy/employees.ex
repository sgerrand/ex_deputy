defmodule Deputy.Employees do
  @moduledoc """
  Functions for interacting with employees in Deputy.
  """

  alias Deputy

  @doc """
  Get all employees.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.list(client)
      {:ok, [%{"Id" => 1, "FirstName" => "John", "LastName" => "Doe"}]}

  """
  @spec list(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def list(client) do
    Deputy.request(client, :get, "/api/v1/supervise/employee")
  end

  @doc """
  Get employee by ID.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee to retrieve.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.get(client, 1)
      {:ok, %{"Id" => 1, "FirstName" => "John", "LastName" => "Doe"}}

  """
  @spec get(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def get(client, id) do
    Deputy.request(client, :get, "/api/v1/supervise/employee/#{id}")
  end

  @doc """
  Add a new employee.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the new employee details.

  ## Employee parameters

  - `strFirstName`: Employee's first name.
  - `strLastName`: Employee's last name.
  - `intCompanyId`: ID of the company/location where the employee works.
  - `intGender`: Integer representing gender (e.g., 1 for male, 2 for female).
  - `strCountryCode`: Country code (e.g., "US").
  - `strDob`: Date of birth in format "YYYY-MM-DD".
  - `strStartDate`: Employment start date in format "YYYY-MM-DD".
  - `strMobilePhone`: Mobile phone number.
  - `strPayrollId`: Optional. Payroll ID.
  - `fltWeekDayRate`: Optional. Weekday pay rate.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   strFirstName: "John",
      ...>   strLastName: "Doe",
      ...>   intCompanyId: 1,
      ...>   intGender: 1,
      ...>   strCountryCode: "US",
      ...>   strDob: "1980-01-01",
      ...>   strStartDate: "2023-01-01",
      ...>   strMobilePhone: "5551234567"
      ...> }
      iex> Deputy.Employees.create(client, attrs)
      {:ok, %{"Id" => 123}}

  """
  @spec create(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def create(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/employee", body: attrs)
  end

  @doc """
  Update an existing employee.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee to update.
  - `attrs`: A map containing the fields to update.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.update(client, 1, %{Phone: "5559876543"})
      {:ok, %{"success" => true}}

  """
  @spec update(Deputy.t(), integer(), map()) :: {:ok, map()} | {:error, any()}
  def update(client, id, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/employee/#{id}", body: attrs)
  end

  @doc """
  Add a location to an employee.

  ## Parameters

  - `client`: A Deputy client.
  - `employee_id`: The ID of the employee.
  - `company_id`: The ID of the location/company to associate with the employee.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.add_location(client, 1, 2)
      {:ok, %{"success" => true}}

  """
  @spec add_location(Deputy.t(), integer(), integer()) :: {:ok, map()} | {:error, any()}
  def add_location(client, employee_id, company_id) do
    Deputy.request(client, :post, "/api/v1/supervise/employee/#{employee_id}/assoc/#{company_id}")
  end

  @doc """
  Remove a location from an employee.

  ## Parameters

  - `client`: A Deputy client.
  - `employee_id`: The ID of the employee.
  - `company_id`: The ID of the location/company to remove from the employee.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.remove_location(client, 1, 2)
      {:ok, %{"success" => true}}

  """
  @spec remove_location(Deputy.t(), integer(), integer()) :: {:ok, map()} | {:error, any()}
  def remove_location(client, employee_id, company_id) do
    Deputy.request(
      client,
      :post,
      "/api/v1/supervise/employee/#{employee_id}/unassoc/#{company_id}"
    )
  end

  @doc """
  Terminate an employee.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee to terminate.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.terminate(client, 1)
      {:ok, %{"success" => true}}

  """
  @spec terminate(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def terminate(client, id) do
    Deputy.request(client, :post, "/api/v1/supervise/employee/#{id}/terminate")
  end

  @doc """
  Reactivate a terminated employee.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee to reactivate.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.reactivate(client, 1)
      {:ok, %{"success" => true}}

  """
  @spec reactivate(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def reactivate(client, id) do
    Deputy.request(client, :post, "/api/v1/supervise/employee/#{id}/activate")
  end

  @doc """
  Delete an employee's account in Deputy.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee to delete.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.delete(client, 1)
      {:ok, %{"success" => true}}

  """
  @spec delete(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def delete(client, id) do
    Deputy.request(client, :post, "/api/v1/supervise/employee/#{id}/delete")
  end

  @doc """
  Invite an employee to Deputy.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee to invite.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.invite(client, 1)
      {:ok, %{"success" => true}}

  """
  @spec invite(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def invite(client, id) do
    Deputy.request(client, :post, "/api/v1/supervise/employee/#{id}/invite")
  end

  @doc """
  Set award for an employee.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee.
  - `attrs`: A map containing the award details.

  ## Award parameters

  - `strCountryCode`: Country code (e.g., "au").
  - `strAwardCode`: Award code.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.set_award(client, 1, %{strCountryCode: "au", strAwardCode: "casual-2021-11-01-aea-2"})
      {:ok, %{"success" => true}}

  """
  @spec set_award(Deputy.t(), integer(), map()) :: {:ok, map()} | {:error, any()}
  def set_award(client, id, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/employee/#{id}/setAwardFromLibrary",
      body: attrs
    )
  end

  @doc """
  Get an employee's current shift information.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.get_shift_info(client, 1)
      {:ok, %{"Status" => "On Shift", "RosterID" => 123}}

  """
  @spec get_shift_info(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def get_shift_info(client, id) do
    Deputy.request(client, :get, "/api/v1/supervise/empshiftinfo/#{id}")
  end

  @doc """
  Get an employee's leave.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.get_leave(client, 1)
      {:ok, [%{"Id" => 123, "DateStart" => "2023-01-01", "DateEnd" => "2023-01-05"}]}

  """
  @spec get_leave(Deputy.t(), integer()) :: {:ok, list(map())} | {:error, any()}
  def get_leave(client, id) do
    Deputy.request(client, :get, "/api/v1/supervise/leave/#{id}")
  end

  @doc """
  Add leave for an employee.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the leave details.

  ## Leave parameters

  - `Status`: Status code for the leave (e.g., 1 for approved).
  - `Employee`: ID of the employee.
  - `DateStart`: Start date in format "YYYY/MM/DD".
  - `DateEnd`: End date in format "YYYY/MM/DD".
  - `ApprovalComment`: Optional. Comment for the leave approval.
  - `ActionOverlappingRosters`: How to handle overlapping rosters (e.g., 0 to keep).

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   Status: 1,
      ...>   Employee: 1,
      ...>   DateStart: "2023/01/01",
      ...>   DateEnd: "2023/01/05",
      ...>   ApprovalComment: "Vacation",
      ...>   ActionOverlappingRosters: 0
      ...> }
      iex> Deputy.Employees.add_leave(client, attrs)
      {:ok, %{"Id" => 123}}

  """
  @spec add_leave(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def add_leave(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/leave/", body: attrs)
  end

  @doc """
  Get unavailability details for an employee.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.get_unavailability(client, 1)
      {:ok, [%{"Id" => 123, "Start" => %{"timestamp" => 1657001675}, "End" => %{"timestamp" => 1657001676}}]}

  """
  @spec get_unavailability(Deputy.t(), integer()) :: {:ok, list(map())} | {:error, any()}
  def get_unavailability(client, id) do
    Deputy.request(client, :get, "/api/v1/supervise/unavail/#{id}")
  end

  @doc """
  Add unavailability for an employee.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the unavailability details.

  ## Unavailability parameters

  - `employee`: ID of the employee.
  - `start`: Map with timestamp for start time.
  - `end`: Map with timestamp for end time.
  - `strComment`: Optional. Comment for the unavailability.
  - `recurrence`: Optional. Map with recurrence pattern.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   employee: 1,
      ...>   start: %{timestamp: 1657001675},
      ...>   end: %{timestamp: 1657001676},
      ...>   strComment: "Weekly appointment",
      ...>   recurrence: %{FREQ: "WEEKLY", INTERVAL: 1, BYDAY: "MO"}
      ...> }
      iex> Deputy.Employees.add_unavailability(client, attrs)
      {:ok, %{"Id" => 123}}

  """
  @spec add_unavailability(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def add_unavailability(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/unavail/", body: attrs)
  end

  @doc """
  Post a journal entry for an employee.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the journal details.

  ## Journal parameters

  - `strComment`: The journal comment.
  - `intEmployeeId`: ID of the employee.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.add_journal(client, %{strComment: "Employee performed well today", intEmployeeId: 1})
      {:ok, %{"Id" => 123}}

  """
  @spec add_journal(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def add_journal(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/journal", body: attrs)
  end

  @doc """
  Get agreed hours for an employee.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Employees.get_agreed_hours(client, 1)
      {:ok, %{"AgreedHours" => 40.0}}

  """
  @spec get_agreed_hours(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def get_agreed_hours(client, id) do
    Deputy.request(client, :get, "/api/management/v2/agreed_hour/#{id}")
  end
end

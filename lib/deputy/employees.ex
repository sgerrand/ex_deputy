defmodule Deputy.Employees do
  @moduledoc """
  Functions for interacting with employees in Deputy.
  """

  alias Deputy.Validation

  @doc """
  Get all employees.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.list(client)
      # => {:ok, [%{"Id" => 1, "FirstName" => "John", "LastName" => "Doe"}]}

  """
  @spec list(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def list(client) do
    Deputy.request(client, :get, "/api/v1/supervise/employee")
  end

  @doc """
  Get employee by ID.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee to retrieve.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.get(client, 1)
      # => {:ok, %{"Id" => 1, "FirstName" => "John", "LastName" => "Doe"}}

  """
  @spec get(Deputy.t(), integer()) :: {:ok, map()} | {:error, Deputy.Error.t()}
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

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      attrs = %{
        strFirstName: "John",
        strLastName: "Doe",
        intCompanyId: 1,
        intGender: 1,
        strCountryCode: "US",
        strDob: "1980-01-01",
        strStartDate: "2023-01-01",
        strMobilePhone: "5551234567"
      }
      Deputy.Employees.create(client, attrs)
      # => {:ok, %{"Id" => 123}}

  """
  @spec create(Deputy.t(), map()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def create(client, attrs) do
    required = [:strFirstName, :strLastName, :intCompanyId]

    with :ok <- Validation.required_fields(attrs, required) do
      Deputy.request(client, :post, "/api/v1/supervise/employee", body: attrs)
    end
  end

  @doc """
  Update an existing employee.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee to update.
  - `attrs`: A map containing the fields to update.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.update(client, 1, %{Phone: "5559876543"})
      # => {:ok, %{"success" => true}}

  """
  @spec update(Deputy.t(), integer(), map()) :: {:ok, map()} | {:error, Deputy.Error.t()}
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

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.add_location(client, 1, 2)
      # => {:ok, %{"success" => true}}

  """
  @spec add_location(Deputy.t(), integer(), integer()) ::
          {:ok, map()} | {:error, Deputy.Error.t()}
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

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.remove_location(client, 1, 2)
      # => {:ok, %{"success" => true}}

  """
  @spec remove_location(Deputy.t(), integer(), integer()) ::
          {:ok, map()} | {:error, Deputy.Error.t()}
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

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.terminate(client, 1)
      # => {:ok, %{"success" => true}}

  """
  @spec terminate(Deputy.t(), integer()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def terminate(client, id) do
    Deputy.request(client, :post, "/api/v1/supervise/employee/#{id}/terminate")
  end

  @doc """
  Reactivate a terminated employee.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee to reactivate.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.reactivate(client, 1)
      # => {:ok, %{"success" => true}}

  """
  @spec reactivate(Deputy.t(), integer()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def reactivate(client, id) do
    Deputy.request(client, :post, "/api/v1/supervise/employee/#{id}/activate")
  end

  @doc """
  Delete an employee's account in Deputy.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee to delete.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.delete(client, 1)
      # => {:ok, %{"success" => true}}

  """
  @spec delete(Deputy.t(), integer()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def delete(client, id) do
    Deputy.request(client, :post, "/api/v1/supervise/employee/#{id}/delete")
  end

  @doc """
  Invite an employee to Deputy.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee to invite.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.invite(client, 1)
      # => {:ok, %{"success" => true}}

  """
  @spec invite(Deputy.t(), integer()) :: {:ok, map()} | {:error, Deputy.Error.t()}
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

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.set_award(client, 1, %{strCountryCode: "au", strAwardCode: "casual-2021-11-01-aea-2"})
      # => {:ok, %{"success" => true}}

  """
  @spec set_award(Deputy.t(), integer(), map()) :: {:ok, map()} | {:error, Deputy.Error.t()}
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

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.get_shift_info(client, 1)
      # => {:ok, %{"Status" => "On Shift", "RosterID" => 123}}

  """
  @spec get_shift_info(Deputy.t(), integer()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def get_shift_info(client, id) do
    Deputy.request(client, :get, "/api/v1/supervise/empshiftinfo/#{id}")
  end

  @doc """
  Get an employee's leave.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.get_leave(client, 1)
      # => {:ok, [%{"Id" => 123, "DateStart" => "2023-01-01", "DateEnd" => "2023-01-05"}]}

  """
  @spec get_leave(Deputy.t(), integer()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
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

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      attrs = %{
        Status: 1,
        Employee: 1,
        DateStart: "2023/01/01",
        DateEnd: "2023/01/05",
        ApprovalComment: "Vacation",
        ActionOverlappingRosters: 0
      }
      Deputy.Employees.add_leave(client, attrs)
      # => {:ok, %{"Id" => 123}}

  """
  @spec add_leave(Deputy.t(), map()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def add_leave(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/leave/", body: attrs)
  end

  @doc """
  Get unavailability details for an employee.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.get_unavailability(client, 1)
      # => {:ok, [%{"Id" => 123, "Start" => %{"timestamp" => 1657001675}, "End" => %{"timestamp" => 1657001676}}]}

  """
  @spec get_unavailability(Deputy.t(), integer()) ::
          {:ok, list(map())} | {:error, Deputy.Error.t()}
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

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      attrs = %{
        employee: 1,
        start: %{timestamp: 1657001675},
        end: %{timestamp: 1657001676},
        strComment: "Weekly appointment",
        recurrence: %{FREQ: "WEEKLY", INTERVAL: 1, BYDAY: "MO"}
      }
      Deputy.Employees.add_unavailability(client, attrs)
      # => {:ok, %{"Id" => 123}}

  """
  @spec add_unavailability(Deputy.t(), map()) :: {:ok, map()} | {:error, Deputy.Error.t()}
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

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.add_journal(client, %{strComment: "Employee performed well today", intEmployeeId: 1})
      # => {:ok, %{"Id" => 123}}

  """
  @spec add_journal(Deputy.t(), map()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def add_journal(client, attrs) do
    Deputy.request(client, :post, "/api/v1/supervise/journal", body: attrs)
  end

  @doc """
  Get agreed hours for an employee.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the employee.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.Employees.get_agreed_hours(client, 1)
      # => {:ok, %{"AgreedHours" => 40.0}}

  """
  @spec get_agreed_hours(Deputy.t(), integer()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def get_agreed_hours(client, id) do
    Deputy.request(client, :get, "/api/management/v2/agreed_hour/#{id}")
  end

  @doc "Same as `list/1` but raises on error."
  @spec list!(Deputy.t()) :: list(map())
  def list!(client), do: client |> list() |> Deputy.unwrap!()

  @doc "Same as `get/2` but raises on error."
  @spec get!(Deputy.t(), integer()) :: map()
  def get!(client, id), do: client |> get(id) |> Deputy.unwrap!()

  @doc "Same as `create/2` but raises on error."
  @spec create!(Deputy.t(), map()) :: map()
  def create!(client, attrs), do: client |> create(attrs) |> Deputy.unwrap!()

  @doc "Same as `update/3` but raises on error."
  @spec update!(Deputy.t(), integer(), map()) :: map()
  def update!(client, id, attrs), do: client |> update(id, attrs) |> Deputy.unwrap!()

  @doc "Same as `add_location/3` but raises on error."
  @spec add_location!(Deputy.t(), integer(), integer()) :: map()
  def add_location!(client, employee_id, company_id),
    do: client |> add_location(employee_id, company_id) |> Deputy.unwrap!()

  @doc "Same as `remove_location/3` but raises on error."
  @spec remove_location!(Deputy.t(), integer(), integer()) :: map()
  def remove_location!(client, employee_id, company_id),
    do: client |> remove_location(employee_id, company_id) |> Deputy.unwrap!()

  @doc "Same as `terminate/2` but raises on error."
  @spec terminate!(Deputy.t(), integer()) :: map()
  def terminate!(client, id), do: client |> terminate(id) |> Deputy.unwrap!()

  @doc "Same as `reactivate/2` but raises on error."
  @spec reactivate!(Deputy.t(), integer()) :: map()
  def reactivate!(client, id), do: client |> reactivate(id) |> Deputy.unwrap!()

  @doc "Same as `delete/2` but raises on error."
  @spec delete!(Deputy.t(), integer()) :: map()
  def delete!(client, id), do: client |> delete(id) |> Deputy.unwrap!()

  @doc "Same as `invite/2` but raises on error."
  @spec invite!(Deputy.t(), integer()) :: map()
  def invite!(client, id), do: client |> invite(id) |> Deputy.unwrap!()

  @doc "Same as `set_award/3` but raises on error."
  @spec set_award!(Deputy.t(), integer(), map()) :: map()
  def set_award!(client, id, attrs), do: client |> set_award(id, attrs) |> Deputy.unwrap!()

  @doc "Same as `get_shift_info/2` but raises on error."
  @spec get_shift_info!(Deputy.t(), integer()) :: map()
  def get_shift_info!(client, id), do: client |> get_shift_info(id) |> Deputy.unwrap!()

  @doc "Same as `get_leave/2` but raises on error."
  @spec get_leave!(Deputy.t(), integer()) :: list(map())
  def get_leave!(client, id), do: client |> get_leave(id) |> Deputy.unwrap!()

  @doc "Same as `add_leave/2` but raises on error."
  @spec add_leave!(Deputy.t(), map()) :: map()
  def add_leave!(client, attrs), do: client |> add_leave(attrs) |> Deputy.unwrap!()

  @doc "Same as `get_unavailability/2` but raises on error."
  @spec get_unavailability!(Deputy.t(), integer()) :: list(map())
  def get_unavailability!(client, id), do: client |> get_unavailability(id) |> Deputy.unwrap!()

  @doc "Same as `add_unavailability/2` but raises on error."
  @spec add_unavailability!(Deputy.t(), map()) :: map()
  def add_unavailability!(client, attrs),
    do: client |> add_unavailability(attrs) |> Deputy.unwrap!()

  @doc "Same as `add_journal/2` but raises on error."
  @spec add_journal!(Deputy.t(), map()) :: map()
  def add_journal!(client, attrs), do: client |> add_journal(attrs) |> Deputy.unwrap!()

  @doc "Same as `get_agreed_hours/2` but raises on error."
  @spec get_agreed_hours!(Deputy.t(), integer()) :: map()
  def get_agreed_hours!(client, id), do: client |> get_agreed_hours(id) |> Deputy.unwrap!()
end

defmodule Deputy.My do
  @moduledoc """
  Functions for interacting with endpoints related to the authenticated user.
  """

  alias Deputy

  @doc """
  Get information about the authenticated user.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.me(client)
      # => {:ok, %{"Id" => 1, "FirstName" => "John", "LastName" => "Doe"}}

  """
  @spec me(Deputy.t()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def me(client) do
    Deputy.request(client, :get, "/api/v1/me")
  end

  @doc """
  Get setup information for the authenticated user.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.setup(client)
      # => {:ok, %{"locations" => [%{"Id" => 1, "Name" => "Main Office"}]}}

  """
  @spec setup(Deputy.t()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def setup(client) do
    Deputy.request(client, :get, "/api/v1/my/setup")
  end

  @doc """
  Get locations where the authenticated user can work.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.locations(client)
      # => {:ok, [%{"Id" => 1, "Name" => "Main Office"}]}

  """
  @spec locations(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def locations(client) do
    Deputy.request(client, :get, "/api/v1/my/location")
  end

  @doc """
  Get a specific location.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the location.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.location(client, 1)
      # => {:ok, %{"Id" => 1, "Name" => "Main Office"}}

  """
  @spec location(Deputy.t(), integer()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def location(client, id) do
    Deputy.request(client, :get, "/api/v1/my/location/#{id}")
  end

  @doc """
  Get the authenticated user's address.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.contact_address(client)
      # => {:ok, %{"Street1" => "123 Main St", "City" => "New York"}}

  """
  @spec contact_address(Deputy.t()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def contact_address(client) do
    Deputy.request(client, :get, "/api/v1/my/contactaddress")
  end

  @doc """
  Get all the authenticated user's addresses including emergency contacts.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.all_contact_addresses(client)
      # => {:ok, [%{"Street1" => "123 Main St", "City" => "New York"}]}

  """
  @spec all_contact_addresses(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def all_contact_addresses(client) do
    Deputy.request(client, :get, "/api/v1/my/contactaddress/all")
  end

  @doc """
  Update the authenticated user's address.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the address details.

  ## Address parameters

  - `ContactName`: Name for the contact.
  - `UnitNo`: Unit number.
  - `Street1`: Street address.
  - `City`: City.
  - `State`: State code.
  - `Postcode`: Postal code.
  - `Country`: Country ID.
  - `Notes`: Optional notes.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      attrs = %{
        ContactName: "John Doe",
        UnitNo: "2",
        Street1: "123 Main St",
        City: "New York",
        State: "NY",
        Postcode: "10001",
        Country: 1
      }
      Deputy.My.update_contact_address(client, attrs)
      # => {:ok, %{"success" => true}}

  """
  @spec update_contact_address(Deputy.t(), map()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def update_contact_address(client, attrs) do
    Deputy.request(client, :post, "/api/v1/my/contactaddress", body: attrs)
  end

  @doc """
  Get the authenticated user's colleagues.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.colleagues(client)
      # => {:ok, [%{"Id" => 2, "FirstName" => "Jane", "LastName" => "Smith"}]}

  """
  @spec colleagues(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def colleagues(client) do
    Deputy.request(client, :get, "/api/v1/my/colleague")
  end

  @doc """
  Get the authenticated user's rosters.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.rosters(client)
      # => {:ok, [%{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}]}

  """
  @spec rosters(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def rosters(client) do
    Deputy.request(client, :get, "/api/v1/my/roster")
  end

  @doc """
  Get the authenticated user's leave requests.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.leave(client)
      # => {:ok, [%{"Id" => 1, "DateStart" => "2023-01-01", "DateEnd" => "2023-01-05"}]}

  """
  @spec leave(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def leave(client) do
    Deputy.request(client, :get, "/api/v1/my/leave")
  end

  @doc """
  Get the authenticated user's unavailability.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.unavailability(client)
      # => {:ok, [%{"Id" => 1, "Start" => %{"timestamp" => 1657001675}}]}

  """
  @spec unavailability(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def unavailability(client) do
    Deputy.request(client, :get, "/api/v1/my/unavail")
  end

  @doc """
  Get the authenticated user's notifications.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.notifications(client)
      # => {:ok, [%{"Id" => 1, "Message" => "You have a new roster"}]}

  """
  @spec notifications(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def notifications(client) do
    Deputy.request(client, :get, "/api/v1/my/notification")
  end

  @doc """
  Get the authenticated user's training.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.training(client)
      # => {:ok, [%{"Id" => 1, "Name" => "Safety Training"}]}

  """
  @spec training(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def training(client) do
    Deputy.request(client, :get, "/api/v1/my/training")
  end

  @doc """
  Get the authenticated user's memos (newsfeed).

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.memos(client)
      # => {:ok, [%{"Id" => 1, "Content" => "Welcome to Deputy"}]}

  """
  @spec memos(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def memos(client) do
    Deputy.request(client, :get, "/api/v1/my/memo")
  end

  @doc """
  Get the authenticated user's tasks.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.tasks(client)
      # => {:ok, [%{"Id" => 1, "TaskName" => "Complete training"}]}

  """
  @spec tasks(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def tasks(client) do
    Deputy.request(client, :get, "/api/v1/my/tasks")
  end

  @doc """
  Complete a task.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the task to complete.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.complete_task(client, 1)
      # => {:ok, %{"success" => true}}

  """
  @spec complete_task(Deputy.t(), integer()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def complete_task(client, id) do
    Deputy.request(client, :get, "/api/v1/my/tasks/#{id}/do")
  end

  @doc """
  Get the authenticated user's timesheets.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.timesheets(client)
      # => {:ok, [%{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}]}

  """
  @spec timesheets(Deputy.t()) :: {:ok, list(map())} | {:error, Deputy.Error.t()}
  def timesheets(client) do
    Deputy.request(client, :get, "/api/v1/my/timesheets")
  end

  @doc """
  Get details for a specific timesheet.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the timesheet.

  ## Examples

      client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      Deputy.My.timesheet_detail(client, 1)
      # => {:ok, %{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}}

  """
  @spec timesheet_detail(Deputy.t(), integer()) :: {:ok, map()} | {:error, Deputy.Error.t()}
  def timesheet_detail(client, id) do
    Deputy.request(client, :get, "/api/v1/my/timesheets/#{id}/detail")
  end

  @doc "Same as `me/1` but raises on error."
  @spec me!(Deputy.t()) :: map()
  def me!(client), do: client |> me() |> Deputy.unwrap!()

  @doc "Same as `setup/1` but raises on error."
  @spec setup!(Deputy.t()) :: map()
  def setup!(client), do: client |> setup() |> Deputy.unwrap!()

  @doc "Same as `locations/1` but raises on error."
  @spec locations!(Deputy.t()) :: list(map())
  def locations!(client), do: client |> locations() |> Deputy.unwrap!()

  @doc "Same as `location/2` but raises on error."
  @spec location!(Deputy.t(), integer()) :: map()
  def location!(client, id), do: client |> location(id) |> Deputy.unwrap!()

  @doc "Same as `contact_address/1` but raises on error."
  @spec contact_address!(Deputy.t()) :: map()
  def contact_address!(client), do: client |> contact_address() |> Deputy.unwrap!()

  @doc "Same as `all_contact_addresses/1` but raises on error."
  @spec all_contact_addresses!(Deputy.t()) :: list(map())
  def all_contact_addresses!(client), do: client |> all_contact_addresses() |> Deputy.unwrap!()

  @doc "Same as `update_contact_address/2` but raises on error."
  @spec update_contact_address!(Deputy.t(), map()) :: map()
  def update_contact_address!(client, attrs),
    do: client |> update_contact_address(attrs) |> Deputy.unwrap!()

  @doc "Same as `colleagues/1` but raises on error."
  @spec colleagues!(Deputy.t()) :: list(map())
  def colleagues!(client), do: client |> colleagues() |> Deputy.unwrap!()

  @doc "Same as `rosters/1` but raises on error."
  @spec rosters!(Deputy.t()) :: list(map())
  def rosters!(client), do: client |> rosters() |> Deputy.unwrap!()

  @doc "Same as `leave/1` but raises on error."
  @spec leave!(Deputy.t()) :: list(map())
  def leave!(client), do: client |> leave() |> Deputy.unwrap!()

  @doc "Same as `unavailability/1` but raises on error."
  @spec unavailability!(Deputy.t()) :: list(map())
  def unavailability!(client), do: client |> unavailability() |> Deputy.unwrap!()

  @doc "Same as `notifications/1` but raises on error."
  @spec notifications!(Deputy.t()) :: list(map())
  def notifications!(client), do: client |> notifications() |> Deputy.unwrap!()

  @doc "Same as `training/1` but raises on error."
  @spec training!(Deputy.t()) :: list(map())
  def training!(client), do: client |> training() |> Deputy.unwrap!()

  @doc "Same as `memos/1` but raises on error."
  @spec memos!(Deputy.t()) :: list(map())
  def memos!(client), do: client |> memos() |> Deputy.unwrap!()

  @doc "Same as `tasks/1` but raises on error."
  @spec tasks!(Deputy.t()) :: list(map())
  def tasks!(client), do: client |> tasks() |> Deputy.unwrap!()

  @doc "Same as `complete_task/2` but raises on error."
  @spec complete_task!(Deputy.t(), integer()) :: map()
  def complete_task!(client, id), do: client |> complete_task(id) |> Deputy.unwrap!()

  @doc "Same as `timesheets/1` but raises on error."
  @spec timesheets!(Deputy.t()) :: list(map())
  def timesheets!(client), do: client |> timesheets() |> Deputy.unwrap!()

  @doc "Same as `timesheet_detail/2` but raises on error."
  @spec timesheet_detail!(Deputy.t(), integer()) :: map()
  def timesheet_detail!(client, id), do: client |> timesheet_detail(id) |> Deputy.unwrap!()
end

defmodule Deputy.My do
  @moduledoc """
  Functions for interacting with endpoints related to the authenticated user.
  """

  alias Deputy

  @doc """
  Get information about the authenticated user.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.me(client)
      {:ok, %{"Id" => 1, "FirstName" => "John", "LastName" => "Doe"}}

  """
  @spec me(Deputy.t()) :: {:ok, map()} | {:error, any()}
  def me(client) do
    Deputy.request(client, :get, "/api/v1/me")
  end

  @doc """
  Get setup information for the authenticated user.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.setup(client)
      {:ok, %{"locations" => [%{"Id" => 1, "Name" => "Main Office"}]}}

  """
  @spec setup(Deputy.t()) :: {:ok, map()} | {:error, any()}
  def setup(client) do
    Deputy.request(client, :get, "/api/v1/my/setup")
  end

  @doc """
  Get locations where the authenticated user can work.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.locations(client)
      {:ok, [%{"Id" => 1, "Name" => "Main Office"}]}

  """
  @spec locations(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def locations(client) do
    Deputy.request(client, :get, "/api/v1/my/location")
  end

  @doc """
  Get a specific location.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the location.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.location(client, 1)
      {:ok, %{"Id" => 1, "Name" => "Main Office"}}

  """
  @spec location(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def location(client, id) do
    Deputy.request(client, :get, "/api/v1/my/location/#{id}")
  end

  @doc """
  Get the authenticated user's address.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.contact_address(client)
      {:ok, %{"Street1" => "123 Main St", "City" => "New York"}}

  """
  @spec contact_address(Deputy.t()) :: {:ok, map()} | {:error, any()}
  def contact_address(client) do
    Deputy.request(client, :get, "/api/v1/my/contactaddress")
  end

  @doc """
  Get all the authenticated user's addresses including emergency contacts.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.all_contact_addresses(client)
      {:ok, [%{"Street1" => "123 Main St", "City" => "New York"}]}

  """
  @spec all_contact_addresses(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
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

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   ContactName: "John Doe",
      ...>   UnitNo: "2",
      ...>   Street1: "123 Main St",
      ...>   City: "New York",
      ...>   State: "NY",
      ...>   Postcode: "10001",
      ...>   Country: 1
      ...> }
      iex> Deputy.My.update_contact_address(client, attrs)
      {:ok, %{"success" => true}}

  """
  @spec update_contact_address(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def update_contact_address(client, attrs) do
    Deputy.request(client, :post, "/api/v1/my/contactaddress", body: attrs)
  end

  @doc """
  Get the authenticated user's colleagues.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.colleagues(client)
      {:ok, [%{"Id" => 2, "FirstName" => "Jane", "LastName" => "Smith"}]}

  """
  @spec colleagues(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def colleagues(client) do
    Deputy.request(client, :get, "/api/v1/my/colleague")
  end

  @doc """
  Get the authenticated user's rosters.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.rosters(client)
      {:ok, [%{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}]}

  """
  @spec rosters(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def rosters(client) do
    Deputy.request(client, :get, "/api/v1/my/roster")
  end

  @doc """
  Get the authenticated user's leave requests.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.leave(client)
      {:ok, [%{"Id" => 1, "DateStart" => "2023-01-01", "DateEnd" => "2023-01-05"}]}

  """
  @spec leave(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def leave(client) do
    Deputy.request(client, :get, "/api/v1/my/leave")
  end

  @doc """
  Get the authenticated user's unavailability.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.unavailability(client)
      {:ok, [%{"Id" => 1, "Start" => %{"timestamp" => 1657001675}}]}

  """
  @spec unavailability(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def unavailability(client) do
    Deputy.request(client, :get, "/api/v1/my/unavail")
  end

  @doc """
  Get the authenticated user's notifications.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.notifications(client)
      {:ok, [%{"Id" => 1, "Message" => "You have a new roster"}]}

  """
  @spec notifications(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def notifications(client) do
    Deputy.request(client, :get, "/api/v1/my/notification")
  end

  @doc """
  Get the authenticated user's training.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.training(client)
      {:ok, [%{"Id" => 1, "Name" => "Safety Training"}]}

  """
  @spec training(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def training(client) do
    Deputy.request(client, :get, "/api/v1/my/training")
  end

  @doc """
  Get the authenticated user's memos (newsfeed).

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.memos(client)
      {:ok, [%{"Id" => 1, "Content" => "Welcome to Deputy"}]}

  """
  @spec memos(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def memos(client) do
    Deputy.request(client, :get, "/api/v1/my/memo")
  end

  @doc """
  Get the authenticated user's tasks.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.tasks(client)
      {:ok, [%{"Id" => 1, "TaskName" => "Complete training"}]}

  """
  @spec tasks(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def tasks(client) do
    Deputy.request(client, :get, "/api/v1/my/tasks")
  end

  @doc """
  Complete a task.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the task to complete.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.complete_task(client, 1)
      {:ok, %{"success" => true}}

  """
  @spec complete_task(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def complete_task(client, id) do
    Deputy.request(client, :get, "/api/v1/my/tasks/#{id}/do")
  end

  @doc """
  Get the authenticated user's timesheets.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.timesheets(client)
      {:ok, [%{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}]}

  """
  @spec timesheets(Deputy.t()) :: {:ok, list(map())} | {:error, any()}
  def timesheets(client) do
    Deputy.request(client, :get, "/api/v1/my/timesheets")
  end

  @doc """
  Get details for a specific timesheet.

  ## Parameters

  - `client`: A Deputy client.
  - `id`: The ID of the timesheet.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.My.timesheet_detail(client, 1)
      {:ok, %{"Id" => 1, "StartTime" => "2023-01-01T09:00:00"}}

  """
  @spec timesheet_detail(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def timesheet_detail(client, id) do
    Deputy.request(client, :get, "/api/v1/my/timesheets/#{id}/detail")
  end
end

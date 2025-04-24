# Deputy

[![Hex Version](https://img.shields.io/hexpm/v/deputy.svg)](https://hex.pm/packages/deputy)
[![Hex Docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/deputy/)

An Elixir client for the [Deputy](https://www.deputy.com/) API,
organized by resource type.

## Installation

This package can be installed by adding `deputy` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:deputy, "~> 0.3"}
  ]
end
```

## Getting Started

First, create a new Deputy client with your API credentials:

```elixir
client = Deputy.new(
  base_url: "https://your-subdomain.deputy.com",
  api_key: "your-api-key"
)
```

Then, use the client to interact with the Deputy API:

```elixir
# Get locations
{:ok, locations} = Deputy.Locations.list(client)

# Get employees
{:ok, employees} = Deputy.Employees.list(client)
```

## API Modules

The library is organized into modules by resource type:

- `Deputy.Locations` - Manage locations (companies)
- `Deputy.Employees` - Manage employees
- `Deputy.Departments` - Manage departments (operational units)
- `Deputy.Rosters` - Manage rosters (schedules)
- `Deputy.Timesheets` - Manage timesheets
- `Deputy.Sales` - Manage sales metrics
- `Deputy.Utility` - Utility functions (time, memos, webhooks, etc.)
- `Deputy.My` - Access endpoints related to the authenticated user

Each module provides functions for interacting with the corresponding Deputy API endpoints.

## Error Handling

All API functions return either `{:ok, result}` or `{:error, error}` tuples. The error can be one of several types:

- `%Deputy.Error.API{}` - API error with details from Deputy (status, code, message)
- `%Deputy.Error.HTTP{}` - HTTP-level error (network issues, server errors)
- `%Deputy.Error.ParseError{}` - Error parsing the API response
- `%Deputy.Error.ValidationError{}` - Request validation failed
- `%Deputy.Error.RateLimitError{}` - Rate limit exceeded

Example of handling different error types:

```elixir
case Deputy.Locations.get(client, 12345) do
  {:ok, location} ->
    # Process location data
    IO.inspect(location)

  {:error, %Deputy.Error.API{status: 404}} ->
    # Handle not found error
    IO.puts("Location not found")

  {:error, %Deputy.Error.HTTP{reason: reason}} ->
    # Handle HTTP error
    IO.puts("HTTP error: #{inspect(reason)}")

  {:error, %Deputy.Error.RateLimitError{retry_after: seconds}} ->
    # Handle rate limit
    IO.puts("Rate limited. Try again in #{seconds} seconds")
end
```

## Bang Functions

Each API function has a corresponding bang (!) version that raises an exception
instead of returning an error tuple. This is useful when you want to fail fast
if an error occurs.

```elixir
# Using regular function with error tuple
{:ok, locations} = Deputy.Locations.list(client)

# Using bang version that raises an exception on error
locations = Deputy.Locations.list!(client)
```

## Examples

### Working with Locations

```elixir
# List all locations
{:ok, locations} = Deputy.Locations.list(client)
# Or using the bang version
locations = Deputy.Locations.list!(client)

# Get a specific location
{:ok, location} = Deputy.Locations.get(client, 123)
# Or using the bang version
location = Deputy.Locations.get!(client, 123)

# Create a new location
attrs = %{
  strWorkplaceName: "New Location",
  strWorkplaceCode: "NLC",
  strAddress: "123 Test St",
  intIsWorkplace: 1,
  intIsPayrollEntity: 1,
  strTimezone: "America/New_York"
}
{:ok, new_location} = Deputy.Locations.create(client, attrs)

# Update a location with error handling
case Deputy.Locations.update(client, 123, %{strWorkplaceCode: "UPD"}) do
  {:ok, updated} ->
    IO.puts("Location updated successfully")

  {:error, %Deputy.Error.API{status: 404}} ->
    IO.puts("Location not found")

  {:error, %Deputy.Error.ValidationError{message: message}} ->
    IO.puts("Validation error: #{message}")
end
```

### Working with Employees

```elixir
# List all employees
{:ok, employees} = Deputy.Employees.list(client)
# Or using the bang version
employees = Deputy.Employees.list!(client)

# Get a specific employee with error handling for rate limits
case Deputy.Employees.get(client, 123) do
  {:ok, employee} ->
    IO.inspect(employee)

  {:error, %Deputy.Error.RateLimitError{retry_after: seconds}} ->
    Process.sleep(seconds * 1000)
    # Retry after waiting
    {:ok, employee} = Deputy.Employees.get(client, 123)
end

# Create a new employee
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

# Using the bang version with exception rescue
try do
  new_employee = Deputy.Employees.create!(client, attrs)
  IO.puts("Employee created successfully")
rescue
  e in Deputy.Error.ValidationError ->
    IO.puts("Validation error: #{e.message}")
  e in Deputy.Error.API ->
    IO.puts("API error (#{e.status}): #{e.message}")
end
```

### Working with Timesheets

```elixir
# Start a timesheet using the bang version
timesheet = Deputy.Timesheets.start!(client, %{
  intEmployeeId: 123,
  intCompanyId: 456
})

# Stop a timesheet with error handling
case Deputy.Timesheets.stop(client, %{intTimesheetId: 789}) do
  {:ok, result} ->
    IO.puts("Timesheet stopped successfully")

  {:error, %Deputy.Error.API{status: 404}} ->
    IO.puts("Timesheet not found")

  {:error, %Deputy.Error.API{status: 400, message: message}} ->
    IO.puts("Bad request: #{message}")

  {:error, %Deputy.Error.HTTP{reason: reason}} ->
    IO.puts("HTTP error: #{inspect(reason)}")
end

# Get timesheet details
{:ok, details} = Deputy.Timesheets.get_details(client, 789)
# Or using the bang version
details = Deputy.Timesheets.get_details!(client, 789)
```

### Working with Authenticated User Data

```elixir
# Get information about the authenticated user
{:ok, user} = Deputy.My.me(client)
# Or using the bang version
user = Deputy.My.me!(client)

# Get locations where the authenticated user can work
{:ok, locations} = Deputy.My.locations(client)

# Get the authenticated user's rosters with error handling
case Deputy.My.rosters(client) do
  {:ok, rosters} ->
    IO.inspect(rosters)

  {:error, %Deputy.Error.API{status: status, message: message}} ->
    IO.puts("API error (#{status}): #{message}")

  {:error, %Deputy.Error.HTTP{reason: :timeout}} ->
    IO.puts("Request timed out, try again later")

  {:error, error} ->
    IO.puts("Unexpected error: #{inspect(error)}")
end

# Get the authenticated user's timesheets
timesheets = Deputy.My.timesheets!(client)
```

## Testing

You can test your code that uses this library by leveraging the
`Deputy.HTTPClient.Mock` provided for testing. This allows you to mock the API
responses in your tests.

```elixir
# In your test setup
Mox.defmock(Deputy.HTTPClient.Mock, for: Deputy.HTTPClient.Behaviour)

test "list employees success" do
  client = Deputy.new(
    base_url: "https://test.deputy.com",
    api_key: "test-key",
    http_client: Deputy.HTTPClient.Mock
  )

  # Set up expectations for success
  Deputy.HTTPClient.Mock
  |> expect(:request, fn opts ->
    assert Keyword.get(opts, :method) == :get
    assert Keyword.get(opts, :url) == "https://test.deputy.com/api/v1/supervise/employee"

    {:ok, [%{"Id" => 1, "FirstName" => "John", "LastName" => "Doe"}]}
  end)

  # Call the function
  {:ok, employees} = Deputy.Employees.list(client)

  # Assertions
  assert length(employees) == 1
  assert hd(employees)["FirstName"] == "John"
end

test "list employees error handling" do
  client = Deputy.new(
    base_url: "https://test.deputy.com",
    api_key: "test-key",
    http_client: Deputy.HTTPClient.Mock
  )

  # Set up expectations for error
  Deputy.HTTPClient.Mock
  |> expect(:request, fn _opts ->
    error = Deputy.Error.from_response(%{
      status: 403,
      body: %{"error" => %{"code" => "permission_denied", "message" => "Permission denied"}}
    })
    {:error, error}
  end)

  # Call the function and test error handling
  assert {:error, %Deputy.Error.API{status: 403, code: "permission_denied"}} =
    Deputy.Employees.list(client)

  # Test bang version raises exception
  assert_raise Deputy.Error.API, fn ->
    Deputy.Employees.list!(client)
  end
end
```

## Documentation

Detailed documentation can be found at <https://hexdocs.pm/deputy>.

## License

Deputy is [released under the MIT license](LICENSE).

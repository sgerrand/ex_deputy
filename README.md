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
    {:deputy, "~> 0.1.0"}
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

## Examples

### Working with Locations

```elixir
# List all locations
{:ok, locations} = Deputy.Locations.list(client)

# Get a specific location
{:ok, location} = Deputy.Locations.get(client, 123)

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

# Update a location
{:ok, updated} = Deputy.Locations.update(client, 123, %{strWorkplaceCode: "UPD"})
```

### Working with Employees

```elixir
# List all employees
{:ok, employees} = Deputy.Employees.list(client)

# Get a specific employee
{:ok, employee} = Deputy.Employees.get(client, 123)

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
{:ok, new_employee} = Deputy.Employees.create(client, attrs)
```

### Working with Timesheets

```elixir
# Start a timesheet
{:ok, timesheet} = Deputy.Timesheets.start(client, %{
  intEmployeeId: 123,
  intCompanyId: 456
})

# Stop a timesheet
{:ok, result} = Deputy.Timesheets.stop(client, %{intTimesheetId: 789})

# Get timesheet details
{:ok, details} = Deputy.Timesheets.get_details(client, 789)
```

### Working with Authenticated User Data

```elixir
# Get information about the authenticated user
{:ok, user} = Deputy.My.me(client)

# Get locations where the authenticated user can work
{:ok, locations} = Deputy.My.locations(client)

# Get the authenticated user's rosters
{:ok, rosters} = Deputy.My.rosters(client)

# Get the authenticated user's timesheets
{:ok, timesheets} = Deputy.My.timesheets(client)
```

## Testing

You can test your code that uses this library by leveraging the
`Deputy.HTTPClient.Mock` provided for testing. This allows you to mock the API
responses in your tests.

```elixir
# In your test setup
Mox.defmock(Deputy.HTTPClient.Mock, for: Deputy.HTTPClient.Behaviour)

test "list employees" do
  client = Deputy.new(
    base_url: "https://test.deputy.com",
    api_key: "test-key",
    http_client: Deputy.HTTPClient.Mock
  )

  # Set up expectations
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
```

## Documentation

Detailed documentation can be found at <https://hexdocs.pm/deputy>.

## License

Deputy is [released under the MIT license](LICENSE).

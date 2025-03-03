defmodule Deputy.Utility do
  @moduledoc """
  Utility functions for interacting with Deputy system features.
  """

  alias Deputy

  @doc """
  Retrieve current system time.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Utility.get_time(client)
      {:ok, %{"time" => 1672531200, "tz" => "UTC"}}

  """
  @spec get_time(Deputy.t()) :: {:ok, map()} | {:error, any()}
  def get_time(client) do
    Deputy.request(client, :get, "/api/v1/time")
  end

  @doc """
  Retrieve current system time for a specific location.

  ## Parameters

  - `client`: A Deputy client.
  - `location_id`: The ID of the location to get time for.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Utility.get_location_time(client, 1)
      {:ok, %{"time" => 1672531200, "tz" => "America/New_York"}}

  """
  @spec get_location_time(Deputy.t(), integer()) :: {:ok, map()} | {:error, any()}
  def get_location_time(client, location_id) do
    Deputy.request(client, :get, "/api/v1/time/#{location_id}")
  end

  @doc """
  Create a memo (announcement).

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the memo details.

  ## Memo parameters

  - `strContent`: Content of the memo.
  - `intCompany`: ID of the company/location.
  - `blnRequireConfirm`: Whether confirmation is required (1 for true, 0 for false).

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   strContent: "Hello, this is a memo",
      ...>   intCompany: 1,
      ...>   blnRequireConfirm: 0
      ...> }
      iex> Deputy.Utility.create_memo(client, attrs)
      {:ok, %{"Id" => 123}}

  """
  @spec create_memo(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def create_memo(client, attrs) do
    Deputy.request(client, :put, "/api/v1/supervise/memo", body: attrs)
  end

  @doc """
  Add a webhook.

  ## Parameters

  - `client`: A Deputy client.
  - `attrs`: A map containing the webhook details.

  ## Webhook parameters

  - `Topic`: Event to subscribe to (e.g., "Timesheet.Insert").
  - `Enabled`: Whether the webhook is enabled (1 for true, 0 for false).
  - `Type`: Type of webhook (e.g., "URL").
  - `Address`: URL to send webhook events to.

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> attrs = %{
      ...>   Topic: "Timesheet.Insert",
      ...>   Enabled: 1,
      ...>   Type: "URL",
      ...>   Address: "https://example.com/webhook"
      ...> }
      iex> Deputy.Utility.add_webhook(client, attrs)
      {:ok, %{"Id" => 123}}

  """
  @spec add_webhook(Deputy.t(), map()) :: {:ok, map()} | {:error, any()}
  def add_webhook(client, attrs) do
    Deputy.request(client, :post, "/api/v1/resource/Webhook", body: attrs)
  end

  @doc """
  Get information about the authenticated user (who am I).

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Utility.who_am_i(client)
      {:ok, %{"Id" => 1, "FirstName" => "John", "LastName" => "Doe"}}

  """
  @spec who_am_i(Deputy.t()) :: {:ok, map()} | {:error, any()}
  def who_am_i(client) do
    Deputy.request(client, :get, "/api/v1/me")
  end

  @doc """
  Get setup information for the authenticated user (where can I work/what do I do).

  ## Examples

      iex> client = Deputy.new(base_url: "https://test.deputy.com", api_key: "test-key")
      iex> Deputy.Utility.get_setup(client)
      {:ok, %{"locations" => [%{"Id" => 1, "Name" => "Main Office"}]}}

  """
  @spec get_setup(Deputy.t()) :: {:ok, map()} | {:error, any()}
  def get_setup(client) do
    Deputy.request(client, :get, "/api/v1/my/setup")
  end
end

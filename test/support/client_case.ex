defmodule Deputy.ClientCase do
  @moduledoc """
  Shared ExUnit case template for resource module tests.

  Wires up `Mox` verification and exposes a `Deputy` client configured
  with the `Deputy.HTTPClient.Mock` adapter via the `:client` context key.
  """

  use ExUnit.CaseTemplate

  import Mox

  using do
    quote do
      import Mox
    end
  end

  setup :verify_on_exit!

  setup do
    client =
      Deputy.new(
        base_url: "https://test.deputy.com",
        api_key: "test-key",
        http_client: Deputy.HTTPClient.Mock
      )

    {:ok, client: client}
  end
end

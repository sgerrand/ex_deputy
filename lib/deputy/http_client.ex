defmodule Deputy.HTTPClient do
  @moduledoc """
  Behaviour for HTTP clients used by Deputy.

  Implementations receive a `Deputy.HTTPClient.Request` struct and
  return `{:ok, response_body}` on success or `{:error, error_term}` on
  failure. The default implementation, `Deputy.HTTPClient.Req`,
  translates the struct into Req options; alternative adapters can map
  the same struct onto any HTTP client.
  """

  alias Deputy.HTTPClient.Request

  @callback request(Request.t()) :: {:ok, map()} | {:error, any()}
end

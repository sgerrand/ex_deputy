defmodule Deputy.HTTPClient do
  @moduledoc """
  Behavior for HTTP clients used by Deputy
  """

  @callback request(keyword()) :: {:ok, map()} | {:error, any()}
end

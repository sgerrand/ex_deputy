defmodule Deputy.HTTPClient.Request do
  @moduledoc """
  Adapter-neutral representation of a single Deputy API HTTP request.

  Built by `Deputy.request/4` and consumed by every
  `Deputy.HTTPClient` implementation. Lets alternative HTTP backends
  exist without speaking Req's keyword-list shape.
  """

  @type t :: %__MODULE__{
          method: atom(),
          url: String.t(),
          headers: [{String.t(), String.t()}],
          body: map() | list() | nil,
          params: map() | keyword() | nil,
          retry: term() | nil,
          adapter_opts: keyword()
        }

  @enforce_keys [:method, :url, :headers]
  defstruct [:method, :url, :headers, :body, :params, :retry, adapter_opts: []]
end

defmodule Deputy.HTTPClient.Req do
  @moduledoc """
  HTTP client implementation using Req
  """
  @behaviour Deputy.HTTPClient

  alias Deputy.Error

  @impl true
  def request(opts) do
    method = Keyword.get(opts, :method)
    url = Keyword.get(opts, :url)
    start_time = System.monotonic_time()

    :telemetry.execute([:deputy, :request, :start], %{system_time: System.system_time()}, %{
      method: method,
      url: url
    })

    result =
      case Req.request(opts) do
        {:ok, %{status: status, body: body, headers: headers}} when status in 200..299 ->
          {:ok, body}

        {:ok, %{status: status, body: body}} ->
          error = Error.from_response(%{status: status, body: body, headers: headers})
          {:error, error}

        {:error, error} ->
          {:error, Error.from_response(error)}
      end

    duration = System.monotonic_time() - start_time

    status =
      case result do
        {:ok, _} -> :ok
        {:error, %{status: s}} when not is_nil(s) -> s
        {:error, _} -> :error
      end

    :telemetry.execute([:deputy, :request, :stop], %{duration: duration}, %{
      method: method,
      url: url,
      status: status
    })

    result
  end
end

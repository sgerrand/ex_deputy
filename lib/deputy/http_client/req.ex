defmodule Deputy.HTTPClient.Req do
  @moduledoc """
  HTTP client implementation using Req.

  See `Deputy`'s moduledoc for the `[:deputy, :request, :start | :stop |
  :exception]` telemetry events emitted around each request.
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

    try do
      result = do_request(opts)
      duration = System.monotonic_time() - start_time

      :telemetry.execute([:deputy, :request, :stop], %{duration: duration}, %{
        method: method,
        url: url,
        status: stop_status(result)
      })

      result
    rescue
      exception ->
        emit_exception(method, url, start_time, :error, exception, __STACKTRACE__)
        reraise exception, __STACKTRACE__
    catch
      kind, reason ->
        emit_exception(method, url, start_time, kind, reason, __STACKTRACE__)
        :erlang.raise(kind, reason, __STACKTRACE__)
    end
  end

  defp do_request(opts) do
    case Req.request(opts) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %{status: status, body: body, headers: headers}} ->
        {:error, Error.from_response(%{status: status, body: body, headers: headers})}

      {:error, error} ->
        {:error, Error.from_response(error)}
    end
  end

  defp stop_status({:ok, _}), do: :ok
  defp stop_status({:error, %{status: s}}) when not is_nil(s), do: s
  defp stop_status({:error, _}), do: :error

  defp emit_exception(method, url, start_time, kind, reason, stacktrace) do
    :telemetry.execute(
      [:deputy, :request, :exception],
      %{duration: System.monotonic_time() - start_time},
      %{
        method: method,
        url: url,
        kind: kind,
        reason: reason,
        stacktrace: stacktrace
      }
    )
  end
end

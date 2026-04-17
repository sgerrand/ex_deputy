defmodule Deputy.HTTPClient.ReqTest do
  use ExUnit.Case, async: false

  alias Deputy.Error.{APIError, HTTPError}
  alias Deputy.HTTPClient.Req, as: HTTPClientReq
  alias Req.Test, as: ReqTest

  describe "request/1" do
    test "returns ok tuple for 2xx response" do
      ReqTest.stub(DeputyReqTest2xx, fn conn ->
        ReqTest.json(conn, %{"data" => "success"})
      end)

      opts = [
        method: :get,
        url: "https://test.deputy.com/api/test",
        headers: [{"Authorization", "Bearer test-key"}],
        plug: {ReqTest, DeputyReqTest2xx}
      ]

      assert {:ok, %{"data" => "success"}} = HTTPClientReq.request(opts)
    end

    test "returns error tuple for 4xx response" do
      ReqTest.stub(DeputyReqTest4xx, fn conn ->
        conn = Map.put(conn, :status, 404)
        ReqTest.json(conn, %{"message" => "Not found"})
      end)

      opts = [
        method: :get,
        url: "https://test.deputy.com/api/test",
        plug: {ReqTest, DeputyReqTest4xx}
      ]

      assert {:error, %APIError{status: 404, message: "Not found"}} =
               HTTPClientReq.request(opts)
    end

    test "returns error tuple for 5xx response" do
      ReqTest.stub(DeputyReqTest5xx, fn conn ->
        conn = Map.put(conn, :status, 500)
        ReqTest.json(conn, %{"error" => "server error"})
      end)

      opts = [
        method: :get,
        url: "https://test.deputy.com/api/test",
        plug: {ReqTest, DeputyReqTest5xx},
        retry: false
      ]

      assert {:error, %HTTPError{status: 500}} = HTTPClientReq.request(opts)
    end

    test "returns error tuple for transport errors" do
      opts = [
        method: :get,
        url: "https://test.deputy.com/api/test",
        adapter: fn request ->
          {request, RuntimeError.exception("connection refused")}
        end
      ]

      assert {:error, %HTTPError{status: nil}} = HTTPClientReq.request(opts)
    end

    test "emits start telemetry event" do
      ReqTest.stub(DeputyReqTestTelemetryStart, fn conn ->
        ReqTest.json(conn, %{})
      end)

      test_pid = self()
      handler_id = "test-deputy-req-start-#{System.unique_integer()}"

      :telemetry.attach(
        handler_id,
        [:deputy, :request, :start],
        fn _event, measurements, metadata, _ ->
          send(test_pid, {:telemetry_start, measurements, metadata})
        end,
        nil
      )

      on_exit(fn -> :telemetry.detach(handler_id) end)

      opts = [
        method: :get,
        url: "https://test.deputy.com/api/telemetry-test",
        plug: {ReqTest, DeputyReqTestTelemetryStart}
      ]

      HTTPClientReq.request(opts)

      assert_receive {:telemetry_start, %{system_time: _}, %{method: :get, url: _}}
    end

    test "emits stop telemetry event with ok status for 2xx" do
      ReqTest.stub(DeputyReqTestTelemetryStop, fn conn ->
        ReqTest.json(conn, %{})
      end)

      test_pid = self()
      handler_id = "test-deputy-req-stop-#{System.unique_integer()}"

      :telemetry.attach(
        handler_id,
        [:deputy, :request, :stop],
        fn _event, measurements, metadata, _ ->
          send(test_pid, {:telemetry_stop, measurements, metadata})
        end,
        nil
      )

      on_exit(fn -> :telemetry.detach(handler_id) end)

      opts = [
        method: :get,
        url: "https://test.deputy.com/api/telemetry-test",
        plug: {ReqTest, DeputyReqTestTelemetryStop}
      ]

      HTTPClientReq.request(opts)

      assert_receive {:telemetry_stop, %{duration: _}, %{method: :get, url: _, status: :ok}}
    end

    test "emits stop telemetry event with status code for api errors" do
      ReqTest.stub(DeputyReqTestTelemetryApiError, fn conn ->
        conn = Map.put(conn, :status, 404)
        ReqTest.json(conn, %{"message" => "Not found"})
      end)

      test_pid = self()
      handler_id = "test-deputy-req-api-error-#{System.unique_integer()}"

      :telemetry.attach(
        handler_id,
        [:deputy, :request, :stop],
        fn _event, measurements, metadata, _ ->
          send(test_pid, {:telemetry_stop, measurements, metadata})
        end,
        nil
      )

      on_exit(fn -> :telemetry.detach(handler_id) end)

      opts = [
        method: :get,
        url: "https://test.deputy.com/api/telemetry-test",
        plug: {ReqTest, DeputyReqTestTelemetryApiError}
      ]

      HTTPClientReq.request(opts)

      assert_receive {:telemetry_stop, %{duration: _}, %{status: 404}}
    end

    test "emits stop telemetry event with :error status for transport errors" do
      test_pid = self()
      handler_id = "test-deputy-req-transport-#{System.unique_integer()}"

      :telemetry.attach(
        handler_id,
        [:deputy, :request, :stop],
        fn _event, measurements, metadata, _ ->
          send(test_pid, {:telemetry_stop, measurements, metadata})
        end,
        nil
      )

      on_exit(fn -> :telemetry.detach(handler_id) end)

      opts = [
        method: :get,
        url: "https://test.deputy.com/api/telemetry-test",
        adapter: fn request ->
          {request, RuntimeError.exception("connection refused")}
        end
      ]

      HTTPClientReq.request(opts)

      assert_receive {:telemetry_stop, %{duration: _}, %{status: :error}}
    end
  end
end

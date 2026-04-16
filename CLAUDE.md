# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development

### Requirements

- Elixir 1.19 / Erlang OTP 28.1 — managed via `asdf` (see `.tool-versions`)

### Setup

```shell
bin/setup   # installs tooling (actionlint, lefthook, markdownlint) and git hooks
mix setup   # installs Elixir dependencies
```

### Commands

| Task | Command |
| ---- | ------- |
| Run all tests | `mix test` |
| Run a single test | `mix test path/to/test_file.exs:line_number` |
| Run a test file | `mix test path/to/test_file.exs` |
| Format code | `mix format` |
| Lint | `mix credo` |
| Generate docs | `mix docs` |

## Architecture

Deputy is an Elixir client library for the Deputy workforce management REST API. It is organized as a thin HTTP client abstraction over resource-oriented API modules.

### Core Layer

- **`Deputy`** (`lib/deputy.ex`) — Entry point. Defines the `%Deputy{}` client struct (`base_url`, `api_key`, `http_client`) and the core `request/4` / `request!/4` functions that all resource modules call.
- **`Deputy.Error`** (`lib/deputy/error.ex`) — Defines five error structs: `APIError`, `HTTPError`, `ParseError`, `ValidationError`, `RateLimitError`. The `from_response/1` function classifies HTTP responses into the appropriate type.
- **`Deputy.HTTPClient.Behaviour`** — Single-callback behaviour (`request/1`) that makes the HTTP layer swappable. Default implementation uses `Req`; tests inject `Deputy.HTTPClient.Mock` via Mox.

### Resource Modules

Each module under `lib/deputy/` maps to a Deputy API domain: `Locations`, `Employees`, `Departments`, `Rosters`, `Timesheets`, `Sales`, `Utility`, `My`. All follow the same conventions:

- Every public function has a regular variant returning `{:ok, data} | {:error, error}` and a bang variant (`list!/1`) that unwraps or raises.
- Operations delegate to `Deputy.request/4` with the method, path, body, and params.
- API endpoints are versioned: `v1` for most resources, `v2` for sales metrics; some management operations use `/api/management/v2/`.

### Testing

Tests live in `test/deputy/` mirroring the lib structure. `test_helper.exs` defines `Deputy.HTTPClient.Mock` and calls `Mox.verify_on_exit!/0`. Each test uses `expect(:request, fn ... end)` to control HTTP responses without network calls.

## Code Style Guidelines

- Use `@moduledoc` and `@doc` with examples for all public modules and functions.
- Validate input with predefined lists; return `ValidationError` for bad types before making HTTP calls.
- Organize modules hierarchically matching the API domain structure.
- Handle all errors via pattern matching on `{:ok, _} | {:error, _}` tuples.

## Git Flow

- Branch naming: `feature-description-ticket-id`
- PRs should include tests and documentation updates

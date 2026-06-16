# Changelog

All notable changes to this project will be documented in this file. See [Keep a
CHANGELOG](http://keepachangelog.com/) for how to update this file. This project
adheres to [Semantic Versioning](http://semver.org/).

## [0.5.1](https://github.com/sgerrand/ex_deputy/compare/v0.5.0...v0.5.1) (2026-06-16)


### Bug Fixes

* **deps:** bump req from 0.5.17 to 0.6.1 ([#73](https://github.com/sgerrand/ex_deputy/issues/73)) ([ebe4920](https://github.com/sgerrand/ex_deputy/commit/ebe492084216d9868d220a580e44fe5fea7a3235))

## [0.5.0](https://github.com/sgerrand/ex_deputy/compare/v0.4.1...v0.5.0) (2026-05-27)


### Features

* **auth:** support OAuth and dpauth schemes via :auth_scheme option ([888d084](https://github.com/sgerrand/ex_deputy/commit/888d084af2e3113f6295634a09cb944293db9d1b))
* **constants:** add defguard predicates alongside value accessors ([8516e9f](https://github.com/sgerrand/ex_deputy/commit/8516e9f83e7fa1ec2e511dc81199ec8052c3f9e2))
* **error:** parse X-RateLimit headers on 429 responses ([c0e7ab5](https://github.com/sgerrand/ex_deputy/commit/c0e7ab5c1f36ceb8526120965b2cb1a8fdf51d15))
* **http:** support :retry option for transient failures ([01b10ed](https://github.com/sgerrand/ex_deputy/commit/01b10ed0dc1513a0aff387e15785faabe0c70e28))
* **telemetry:** emit [:deputy, :request, :exception] on raise/throw/exit ([81472b6](https://github.com/sgerrand/ex_deputy/commit/81472b6e6d1bd3eb44130162263659ef1c593d87))
* **validation:** reject nil/empty values and validate timesheet ops ([a4d01c6](https://github.com/sgerrand/ex_deputy/commit/a4d01c64e2d16bcd6dd15b0a46441f97521f2917))
* **validation:** require documented fields in remaining create/update calls ([3542d40](https://github.com/sgerrand/ex_deputy/commit/3542d40555e15651d67464c6ba964192f785a566))

## [0.4.1](https://github.com/sgerrand/ex_deputy/compare/v0.4.0...v0.4.1) (2026-04-20)


### Bug Fixes

* **deps:** bump credo from 1.7.17 to 1.7.18, telemetry from 1.3.0 to 1.4.1 ([#63](https://github.com/sgerrand/ex_deputy/issues/63)) ([f09519f](https://github.com/sgerrand/ex_deputy/commit/f09519fa094b31a4944741883b2fc8d9a4413791))

## [0.4.0](https://github.com/sgerrand/ex_deputy/compare/v0.3.0...v0.4.0) (2026-04-17)


### Features

* add bang function variants to all resource modules ([#53](https://github.com/sgerrand/ex_deputy/issues/53)) ([3c0b952](https://github.com/sgerrand/ex_deputy/commit/3c0b952302ba14f551d2aa3db40ff6f99ed0af9c))
* **constants:** add named constants for API enum values ([#58](https://github.com/sgerrand/ex_deputy/issues/58)) ([eb18a1b](https://github.com/sgerrand/ex_deputy/commit/eb18a1bdea900efa055888ec73141a58184409f1))
* **telemetry:** emit telemetry events for API requests ([#59](https://github.com/sgerrand/ex_deputy/issues/59)) ([0ba117d](https://github.com/sgerrand/ex_deputy/commit/0ba117da6022e3b781cd096064abd0d109f9a289))
* validate required fields before API calls ([#55](https://github.com/sgerrand/ex_deputy/issues/55)) ([b04a725](https://github.com/sgerrand/ex_deputy/commit/b04a725896d03dca2edd018408162a2d30300de7))


### Bug Fixes

* **error:** read Retry-After header for rate limit errors ([#49](https://github.com/sgerrand/ex_deputy/issues/49)) ([42db2de](https://github.com/sgerrand/ex_deputy/commit/42db2de6f3a3da09bf7760b73baaa562f63f2409))
* **test:** remove unused test/support path from elixirc_paths ([#47](https://github.com/sgerrand/ex_deputy/issues/47)) ([e59c515](https://github.com/sgerrand/ex_deputy/commit/e59c51515cfadec435ac1ba21c9faab8bc48aa42))

## 0.3.0 - 2025-04-24

### Changes

- Renamed exception modules for consistency

## 0.2.1 - 2025-03-04

### Changes

- Fixed changelog URL in package metadata

## 0.2.0 - 2025-03-04

### Changes

- Introduce centralised error types and handling functions.
- Improve presentation of package documentation.
- Update package metadata with additional links, etc.

## 0.1.0 - 2025-03-03

Initial version. :rocket:

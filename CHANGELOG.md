# Changelog

All notable changes to this project will be documented in this file. See [Keep a
CHANGELOG](http://keepachangelog.com/) for how to update this file. This project
adheres to [Semantic Versioning](http://semver.org/).

<!-- %% CHANGELOG_ENTRIES %% -->

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

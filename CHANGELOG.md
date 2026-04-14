# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this gem adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-04-14

### Added
- `#concat(*values)` to push multiple values at once
- `#percentile(p)` for arbitrary percentile calculation with linear interpolation
- `#sample(n)` to return random element(s) from the buffer

## [0.4.0] - 2026-04-14

### Added
- `#resize(new_capacity)` to dynamically change buffer capacity while preserving elements
- `#inspect` for human-readable string representation

### Fixed
- Bug report template: Ruby version now required, gem version field added
- Feature request template: added "Alternatives considered" field and API placeholder

## [0.3.0] - 2026-04-09

### Added
- `#shift` removes and returns the oldest element
- `#pop` removes and returns the newest element
- `#oldest` and `#newest` peek without mutating

### Changed
- Internal `to_a` now derives the start index from `@head` and `@count`, supporting consumption via `shift`/`pop` while preserving all existing semantics

## [0.2.0] - 2026-04-03

### Added
- Index-based access via `[]` with positive and negative indices
- `first` method for accessing oldest elements
- `clear` method to reset buffer state
- Statistical methods: `variance`, `stddev`, `median`

## [0.1.6] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.5] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.4] - 2026-03-26

### Changed

- Add Sponsor badge and fix License link format in README

## [0.1.3] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements
- Remove inline comments from Development section to match template

## [0.1.2] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes

## [0.1.1] - 2026-03-22

### Changed
- Update rubocop configuration for Windows compatibility

## [0.1.0] - 2026-03-22

### Added

- Initial release
- Fixed-capacity circular buffer with overflow
- Push with automatic oldest-entry eviction
- Statistics: average, sum, min, max
- Last-n element retrieval
- Enumerable support

[0.5.0]: https://github.com/philiprehberger/rb-ring-buffer/releases/tag/v0.5.0
[0.4.0]: https://github.com/philiprehberger/rb-ring-buffer/releases/tag/v0.4.0
[0.3.0]: https://github.com/philiprehberger/rb-ring-buffer/releases/tag/v0.3.0
[0.2.0]: https://github.com/philiprehberger/rb-ring-buffer/releases/tag/v0.2.0
[0.1.6]: https://github.com/philiprehberger/rb-ring-buffer/releases/tag/v0.1.6
[0.1.5]: https://github.com/philiprehberger/rb-ring-buffer/releases/tag/v0.1.5
[0.1.4]: https://github.com/philiprehberger/rb-ring-buffer/releases/tag/v0.1.4
[0.1.3]: https://github.com/philiprehberger/rb-ring-buffer/releases/tag/v0.1.3
[0.1.2]: https://github.com/philiprehberger/rb-ring-buffer/releases/tag/v0.1.2
[0.1.1]: https://github.com/philiprehberger/rb-ring-buffer/releases/tag/v0.1.1
[0.1.0]: https://github.com/philiprehberger/rb-ring-buffer/releases/tag/v0.1.0

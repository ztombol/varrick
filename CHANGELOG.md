# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).


## [Unreleased]

### Added

- Ubuntu 12.04 support (GNU make 3.81 and bash 4.2.25)

### Changed

- Use `env` in shebangs for portability
- Migrate test suite to `bats-assert`

### Removed

- Move Arch Linux packages to separate repositories

### Fixed

- Failing to load the library when it is installed under a custom path
- Usage missing options `--help` and `--usage`
- Documentation claiming *GPLv3* instead of *GPLv3 or later*


## [0.2.0] - 2015-04-11

[***Manta Ray*** ``-<`-`>``](https://en.wikipedia.org/wiki/Manta_ray)

*"Manta Ray, a cleaning station visiting, breaching, clever, curious and
magnificent creature that is vulnerable to extinction due to
overfishing." -- Zoltan Tombol*

### Added

- Man page
- Make file
- Arch Linux packages
- Build and installation instructions

### Changed

- Library functions disable escaping by default
- Preprocessing escapes the input even in absence of variable references

### Fixed

- Mix-up of slash and backslash in documentation and comments
- Escape handling for --no-expand and --missing

## 0.1.0 - 2015-03-06

[***Axolotl*** ``>(`-`)<``](https://en.wikipedia.org/wiki/Axolotl)

*"Axolotl, a cancer-resisting, regenerating cute little animal that is now unfortunately extinct in the wild." -- Zoltan Tombol*

### Added

- Expanding a template
- Option to list undefined references
- Option to skip expanding undefined references
- Option to display referenced and escaped variables
- Option to enable escaping
- Option to check templates for invalid escaping
- Option to pre-process input by escaping reference looking strings
- Split into script and library
- This change log


[Unreleased]: https://github.com/ztombol/varrick/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/ztombol/varrick/compare/v0.1.0...v0.2.0

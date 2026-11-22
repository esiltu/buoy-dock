# Changelog

All notable changes to Buoy are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and Buoy uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.2.0] - 2026-11-22

### Changed

- New warm app icon (ember orange with a paper-white dock bar), matching the new website.
- README images now use the same warm look, with a light settings window.

### Added

- Website: https://esiltu.github.io/buoy-dock/

## [1.1.0] - 2026-11-22

### Added

- Buoy works inside full-screen apps: it stays hidden there and slides up when you push the pointer against the bottom edge, then slides away again when you move off it.

### Changed

- Entering a full-screen app hides the dock right away, so nothing lingers while you swipe between Spaces.

## [1.0.1] - 2026-11-22

### Fixed

- The dock could stay gone after returning to the desktop when Buoy was started, or a Space switch happened, while a full-screen app was active. Buoy now checks again right after every Space switch and keeps a light watchdog that brings the dock back whenever a desktop is active.
- **Show Dock** in the menu bar now always brings the dock back on the desktop you're looking at.

## [1.0.0] - 2026-11-22

First public release. Buoy was developed privately under the working name "Zweef"; its settings are imported automatically.

### Added

- Floating Liquid Glass dock with magnification and labels under the pointer.
- Hiding modes: *Dodge windows* (default), *Auto-hide* and *Always visible*.
- The dock stays on your desktop Space: it slides away with the desktop during Space swipes, never floats over full-screen apps, and is hidden in Mission Control.
- Drag to reorder, drag up to remove, drop apps from Finder to add, drop files on the Trash.
- Right-click menu: Open/Show, Keep in Dock, Remove from Dock, Show in Finder, Quit.
- Running-app dots, a section for open apps you haven't pinned, and a launch animation.
- Imports the apps from the macOS Dock on first launch.
- One-click hide and exact restore of the macOS Dock (auto-hide plus a small Dock at the left edge, because macOS 27 ignores the auto-hide delay).
- Menu bar item with Settings, show/hide dock and a link to star Buoy on GitHub.
- Settings for icon size, magnification, distance from the bottom, open apps, Trash and opening at login.
- `build.sh` with `--install` and `--zip`, and universal (Apple silicon + Intel) builds.

[Unreleased]: https://github.com/esiltu/buoy-dock/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/esiltu/buoy-dock/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/esiltu/buoy-dock/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/esiltu/buoy-dock/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/esiltu/buoy-dock/releases/tag/v1.0.0

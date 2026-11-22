# Changelog

All notable changes to Buoy are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and Buoy uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/esiltu/buoy-dock/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/esiltu/buoy-dock/releases/tag/v1.0.0

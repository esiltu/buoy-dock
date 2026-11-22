<p align="center">
  <img src="docs/icon.png?v=1.2.0" width="128" alt="Buoy app icon">
</p>

<h1 align="center">Buoy</h1>

<p align="center">
  <strong>A floating Liquid Glass dock for macOS. Free and open source.</strong><br>
  It floats above your desktop, gets out of the way of your windows, and never asks for money.<br><br>
  <a href="https://esiltu.github.io/buoy-dock/"><strong>Website</strong></a> ·
  <a href="https://github.com/esiltu/buoy-dock/releases/latest"><strong>Download</strong></a> ·
  <a href="#how-to-use-it"><strong>How to use</strong></a> ·
  <a href="CHANGELOG.md"><strong>Changelog</strong></a>
</p>

<p align="center">
  <a href="https://github.com/esiltu/buoy-dock/releases/latest"><img alt="Download the latest release" src="https://img.shields.io/github/v/release/esiltu/buoy-dock?label=download&style=for-the-badge&color=c2410c"></a>
  <img alt="Requires macOS 26 or later" src="https://img.shields.io/badge/macOS-26%2B-1d1814?style=for-the-badge&logo=apple&logoColor=white">
  <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/github/license/esiltu/buoy-dock?style=for-the-badge&color=1d1814"></a>
  <a href="https://github.com/esiltu/buoy-dock/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/esiltu/buoy-dock?style=for-the-badge&color=c2410c"></a>
</p>

<p align="center">
  <a href="https://www.producthunt.com/products/buoy-4?embed=true&utm_source=badge-featured&utm_medium=badge&utm_campaign=badge-buoy-a6b36018-36b8-44ba-b913-24483b525dd6" target="_blank" rel="noopener noreferrer">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=1326312&theme=dark">
      <img alt="Buoy, a free floating dock for macOS, on Product Hunt" width="250" height="54" src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=1326312&theme=light">
    </picture>
  </a>
</p>

<p align="center">
  <img src="docs/hero.png?v=1.2.0" alt="Buoy floating above the desktop, magnifying the Photos icon under the pointer">
</p>

## Why pay when it's free?

Dock replacements usually come with a price tag or a subscription. Buoy costs nothing. No license key, no trial, no account, no ads, no tracking. The whole source code is right here, so you can read every line, change whatever you like and build it yourself.

**Like Buoy? Give it a ⭐ star** and an [upvote on Product Hunt](https://www.producthunt.com/products/buoy-4). It takes one click and helps other people find it. Know someone who'd enjoy a nicer dock? **Send them the link.**

## Features

- **Liquid Glass bar** that floats above the bottom edge of your screen.
- **Smooth magnification** with the app's name above the icon under your pointer.
- **Dodges your windows.** When the active window reaches the dock, Buoy slides away. Push the pointer against the bottom edge to bring it back.
- **Plays nice with full-screen apps.** Hidden while you swipe between Spaces and in Mission Control. In a full-screen app, push the pointer against the bottom edge and Buoy slides up right there.
- **Drag and drop.** Drag icons to reorder them, drag one up to remove it, drop an app from Finder to add it, drop files on the Trash.
- **Right-click menu** with Open/Show, Keep in Dock, Remove from Dock, Show in Finder and Quit.
- **Open apps** get a dot, and apps you haven't pinned show up after a divider.
- **Imports your current Dock** on first launch, so your apps are already there.
- **One click to tuck Apple's Dock away**, one click to bring it back exactly as it was.
- **Native and light.** Written in Swift and SwiftUI, runs from the menu bar, no Electron.

## Download and install

1. Open the [latest release](https://github.com/esiltu/buoy-dock/releases/latest) and download **`Buoy-<version>.zip`** under *Assets*.
2. Double-click the zip to unzip it, then drag **Buoy.app** into your **Applications** folder.
3. Open Buoy. Because Buoy isn't notarized by Apple (that requires a paid developer account), macOS warns you the first time. Pick one of these:
   - Open **System Settings › Privacy & Security**, scroll down and click **Open Anyway** next to the message about Buoy.
   - Or run this once in Terminal:

     ```bash
     xattr -dr com.apple.quarantine /Applications/Buoy.app
     ```

4. Buoy asks whether it may tuck the macOS Dock away. Click **Hide macOS Dock**. That's it.

Buoy runs on macOS 26 Tahoe and later, on Apple silicon and Intel Macs.

## Build from source

You need macOS 26 or later and Xcode 26 (Swift 6.2 or newer).

```bash
git clone https://github.com/esiltu/buoy-dock.git
cd buoy-dock
./build.sh --install
```

No git? Click the green **Code** button on this page and choose **Download ZIP**. Unzip it, open Terminal in the unzipped folder and run `./build.sh --install`.

| Command | What it does |
| --- | --- |
| `./build.sh` | Builds `build/Buoy.app` |
| `./build.sh --install` | Builds, copies Buoy to `~/Applications` and launches it |
| `./build.sh --zip` | Builds and packs `dist/Buoy-<version>.zip`, ready to attach to a release |

You can also open `Package.swift` in Xcode.

## How to use it

| Do this | To |
| --- | --- |
| Click an icon | Open the app, or bring it to the front |
| Right-click an icon | Open/Show, Keep in Dock, Remove from Dock, Show in Finder, Quit |
| Drag an icon left or right | Reorder your apps |
| Drag an icon up, out of the dock | Remove it |
| Drop an app from Finder on the dock | Add it |
| Drop files on the Trash | Move them to the Trash |
| Push the pointer against the bottom edge | Bring a hidden dock back, also inside full-screen apps |
| Click the menu bar icon | Open Settings, hide the dock, quit |

Double-clicking Buoy.app while it's running also opens Settings.

<p align="center">
  <img src="docs/settings.png?v=1.2.0" width="560" alt="Buoy settings window">
</p>

### Settings

| Setting | What it does |
| --- | --- |
| **macOS Dock** | Hide Apple's Dock, or restore it exactly as it was |
| **Icon size** | 36 to 80 points |
| **Magnification** | Off up to 2× |
| **Distance from bottom** | How high the dock floats, 0 to 48 points |
| **Hiding** | *Dodge windows* (default), *Auto-hide* or *Always visible* |
| **Show open apps** | Show running apps you haven't pinned |
| **Show Trash** | Show the Trash at the end of the dock |
| **Open at login** | Start Buoy automatically |
| **Import from macOS Dock** | Copy the apps from Apple's Dock again |

## About Apple's Dock

macOS doesn't let apps switch its own Dock off, and on macOS 27 the auto-hide delay is ignored, so a hidden Dock still pops up at the bottom edge. When you click **Hide macOS Dock**, Buoy therefore turns on auto-hide and moves Apple's Dock, at its smallest size, to the left edge. Your original Dock settings are saved first, and **Settings › macOS Dock › Restore macOS Dock** puts them back exactly.

To restore it by hand instead (you'll have to pick your own size again afterwards):

```bash
defaults delete com.apple.dock orientation; defaults delete com.apple.dock autohide-delay; defaults write com.apple.dock autohide -bool false; killall Dock
```

## Known limitations

- **Mission Control always shows Apple's Dock.** It's drawn by Mission Control itself and no app can turn that off. Buoy keeps it as small as macOS allows, at the left edge.
- **Minimized windows** go to Apple's hidden Dock, not to Buoy.
- **No notification badges.** macOS doesn't share them with other apps.

## Changelog

Every release is listed in [CHANGELOG.md](CHANGELOG.md) and on the [Releases](https://github.com/esiltu/buoy-dock/releases) page.

## Contributing

Found a bug or have an idea? [Open an issue](https://github.com/esiltu/buoy-dock/issues). Pull requests are welcome too.

## License

Buoy is released under the [MIT License](LICENSE). Use it, share it, change it.

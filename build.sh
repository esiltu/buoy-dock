#!/usr/bin/env bash
# Builds Buoy.app into ./build.
#   ./build.sh            build only
#   ./build.sh --install  build, copy to ~/Applications and launch
#   ./build.sh --zip      build and create dist/Buoy-<version>.zip for a GitHub release
set -euo pipefail
cd "$(dirname "$0")"

APP="build/Buoy.app"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)"
ARCHS=(--arch arm64 --arch x86_64)

swift build -c release "${ARCHS[@]}"
BIN_DIR="$(swift build -c release "${ARCHS[@]}" --show-bin-path)"

[ -f Resources/AppIcon.icns ] || swift scripts/make-icon.swift Resources

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/Buoy" "$APP/Contents/MacOS/Buoy"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
codesign --force --sign - "$APP" 2>/dev/null

echo "Built $APP ($VERSION)"

case "${1:-}" in
  --install)
    pkill -x Buoy || true
    pkill -x Zweef || true   # early preview name
    mkdir -p "$HOME/Applications"
    rm -rf "$HOME/Applications/Buoy.app" "$HOME/Applications/Zweef.app"
    cp -R "$APP" "$HOME/Applications/"
    open "$HOME/Applications/Buoy.app"
    echo "Installed in ~/Applications and launched."
    ;;
  --zip)
    mkdir -p dist
    ZIP="dist/Buoy-$VERSION.zip"
    rm -f "$ZIP"
    ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"
    echo "Created $ZIP"
    ;;
esac

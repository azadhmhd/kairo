#!/usr/bin/env bash
#
# Builds Kairo for release and packages it as a DMG in dist/.
#
#   ./scripts/package-dmg.sh
#
# The version comes from apps/desktop/pubspec.yaml. Pass one to override:
#
#   ./scripts/package-dmg.sh 1.2.0
#
# Everything here ships with macOS — there is nothing to install. The same
# script runs locally and in .github/workflows/release.yml, so a DMG built by
# hand and a DMG built by CI are the same DMG.

set -euo pipefail

cd "$(dirname "$0")/.."

# fvm locally, plain flutter on a CI runner that pins the SDK itself.
if command -v fvm >/dev/null 2>&1 && [ -f .fvmrc ]; then
  flutter() { command fvm flutter "$@"; }
fi

version="${1:-$(grep '^version:' apps/desktop/pubspec.yaml | sed 's/^version: *//; s/+.*//')}"
app="apps/desktop/build/macos/Build/Products/Release/Kairo.app"
dmg="dist/Kairo-${version}.dmg"

echo "==> Building Kairo $version"
( cd apps/desktop && flutter build macos --release )

[ -d "$app" ] || { echo "no app bundle at $app" >&2; exit 1; }

echo "==> Packaging $dmg"
mkdir -p dist
rm -f "$dmg"

# A staging folder holding the app beside a symlink to /Applications, which is
# what gives the DMG the familiar drag-to-install window.
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

# ditto rather than cp -R: it preserves the extended attributes and internal
# symlinks of a bundle, which is what keeps the code signature valid.
ditto "$app" "$stage/Kairo.app"
ln -s /Applications "$stage/Applications"

hdiutil create \
  -volname "Kairo" \
  -srcfolder "$stage" \
  -format UDZO \
  -ov \
  "$dmg" >/dev/null

echo "==> $dmg  ($(du -h "$dmg" | cut -f1))"

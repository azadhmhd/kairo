#!/usr/bin/env bash
#
# Builds Kairo for release and packages it as a DMG in dist/.
#
#   ./scripts/package-dmg.sh          version from apps/desktop/pubspec.yaml
#   ./scripts/package-dmg.sh 1.2.0    explicit version

set -euo pipefail

cd "$(dirname "$0")/.."

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

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

ditto "$app" "$stage/Kairo.app"
ln -s /Applications "$stage/Applications"

hdiutil create \
  -volname "Kairo" \
  -srcfolder "$stage" \
  -format UDZO \
  -ov \
  "$dmg" >/dev/null

echo "==> $dmg  ($(du -h "$dmg" | cut -f1))"

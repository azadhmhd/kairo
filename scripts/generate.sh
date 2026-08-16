#!/usr/bin/env bash
#
# Regenerates everything that is generated: the native platform bridge from its
# Pigeon schema, and the database classes from their Drift tables.
#
# Run after changing either. Generated files are committed, so a stale one is a
# build that disagrees with its source.

set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

if command -v fvm >/dev/null 2>&1 && [ -f "$root/.fvmrc" ]; then
  dart=(fvm dart)
else
  dart=(dart)
fi

echo "Generating the platform bridge..."
(
  cd "$root/packages/kairo_desktop_engine"
  "${dart[@]}" run pigeon --input pigeons/platform_bridge.dart
)

echo "Generating the database..."
(
  cd "$root/packages/kairo_storage"
  "${dart[@]}" run build_runner build --delete-conflicting-outputs
)

echo "Done."

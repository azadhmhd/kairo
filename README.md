# Kairo

Your AI health companion — an offline-first desktop companion that helps you
build healthier computer habits through an interactive animated character.

Kairo is a native Flutter desktop application. It is not a SaaS, not a web app
and not Electron.

## Principles

- **Offline first.** Everything works without a network. No mandatory API calls,
  no cloud storage, no accounts.
- **Privacy first.** All data stays on your machine. Nothing is uploaded,
  tracked or collected.
- **Source available.** Every line is public and readable. Noncommercial use is
  free; see [Licence](#licence).

## Status

Version 1 is in development. The application runs: the dashboard, reminders,
reports and settings are in place, reminders fire on schedule, and the
character walks onto the desktop to deliver them. Packaging and Windows support
come next.

See [docs/architecture/overview.md](docs/architecture/overview.md) for the
design and [docs/adr/](docs/adr/) for the decisions behind it.

No AI ships in version 1. When it arrives it will observe the application, not
drive it — Kairo works completely without a model.

## Requirements

- macOS 13 or later. Windows and Linux come after version 1.
- [FVM](https://fvm.app) with Flutter 3.44.7, pinned in `.fvmrc`
- [Melos](https://melos.invertase.dev) for the monorepo

## Getting started

```bash
dart pub global activate melos
fvm install
melos bootstrap
melos run analyze

cd apps/desktop && fvm flutter run -d macos
```

`melos run generate` regenerates everything that is generated — the native
platform bridge from its Pigeon schema, and the database classes from their
Drift tables. Run it after changing either. Generated files are committed, so a
stale one is a build that disagrees with its source.

## Layout

```
apps/desktop/               The Flutter application
packages/
  kairo_shared_models/      Immutable data shared across the app
  kairo_storage/            SQLite and repositories
  kairo_design_system/      Colours, spacing, type, theme
  kairo_event_bus/          How features talk without knowing each other
  kairo_scheduler/          When something is due
  kairo_workflow_engine/    Triggers, conditions, actions
  kairo_reminder_engine/    Water, stand, eye breaks
  kairo_character_engine/   The character rig
  kairo_desktop_engine/     Windows, overlays, the native bridge
assets/                     Character sheet and application icon
docs/                       Architecture and decision records
```

## Licence

[PolyForm Noncommercial 1.0.0](LICENSE). Copyright © 2026
[Azad Mohamed](https://github.com/azadhmhd).

Read it, run it, fork it, learn from it, contribute to it — any noncommercial
use is free and needs no permission. Selling Kairo or a derivative of it does
need permission; open an issue.

This makes Kairo **source-available rather than open source**: the Open Source
Definition does not allow a licence to restrict commercial use.
[ADR-0006](docs/adr/ADR-0006-licence.md) records why.

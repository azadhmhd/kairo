# Kairo

An offline-first desktop companion that helps you build healthier computer
habits through an interactive animated character.

Native Flutter desktop. Not a SaaS, not a web app, not Electron.

## Demo

![Kairo walking on to deliver a reminder, and leaving once it is answered](assets/kairo_demo.gif)

> 🙂 **Want to help?** Two things I would love a hand with. If you draw, the
> anime character could use a better artist than me — new poses, expressions or
> a whole redesign, all very welcome. And if you are on Windows, nothing has
> been tested there yet and I only have a Mac. Open an issue and say hello.

## What it does

- Fires reminders on a schedule you set — water, standing, eye breaks, and any
  custom reminder you write yourself.
- Delivers each one through a character that walks onto the desktop, and through
  a banner in the main window.
- Re-asks every minute while a reminder is unanswered, up to five times, then
  records it as ignored.
- Records every firing and its outcome: done, ignored, turned down, snoozed.
- Reports completion rates, per-day and per-reminder counts, and streaks.
- Optionally uses a language model you choose to reword reminders you keep
  ignoring, vary what the character says, and write you a summary.

## Principles

- **Offline first.** Everything works without a network. No mandatory API calls,
  no cloud storage, no accounts.
- **Privacy first.** All data stays on your machine, in one SQLite file. Nothing
  is uploaded, tracked or collected.
- **AI is optional.** Off by default. Every feature above except the last works
  with no model configured.
- **Source available.** Every line is public. Noncommercial use is free; see
  [Licence](#licence).

## Status

Version 1, in development. Runs on macOS 13+, packages as a DMG, not yet signed
or notarised. Windows comes after version 1.

Design: [docs/architecture/overview.md](docs/architecture/overview.md).
Decisions: [docs/adr/](docs/adr/).

## Install

**1. Download** `Kairo-<version>.dmg` from
[Releases](https://github.com/azadhmhd/kairo/releases), or:

```bash
gh release download --repo azadhmhd/kairo --pattern '*.dmg'
```

**2. Install.** Open the DMG, drag Kairo onto Applications, eject the image.

**3. Approve it.** Required — Kairo is ad-hoc signed rather than notarised, so
Gatekeeper reports it as damaged until you clear the quarantine flag. It is not
damaged; that is the wording macOS uses for any app without a paid Apple
Developer account. Once per install:

```bash
xattr -dr com.apple.quarantine /Applications/Kairo.app
```

**4. Launch** from Applications or Launchpad.

No account, no sign-in, no network on first run. Three reminders are seeded —
water, standing, eye breaks — editable in Settings.

Uninstall: quit from the menu bar, drag `/Applications/Kairo.app` to the Trash.

### Where it lives

Kairo has **no Dock icon**. It runs in the menu bar — the leaf, top right.

| Action | Result |
| --- | --- |
| Menu bar → Open Dashboard | Brings the window back |
| Closing the dashboard | Window hides, reminders keep running |
| Menu bar → Quit Kairo | Exits |

The character can be switched off in Settings; reminders continue without it.

## AI

Off by default. Kairo never requires a model, and never blocks on one.

### Setup

Settings → Coaching → on, then fill in three fields:

| Field | Value |
| --- | --- |
| Address | An OpenAI-compatible base URL |
| Model | The model name as that service names it |
| API key | Empty for a local model |

**Address** examples:

| Runtime | Address |
| --- | --- |
| Ollama | `http://localhost:11434/v1` |
| LM Studio | `http://localhost:1234/v1` |
| llama.cpp server | `http://localhost:8080/v1` |
| Open WebUI | `https://your-host/api/chat/completions` |
| OpenAI | `https://api.openai.com/v1` |

`/chat/completions` is appended unless the address already ends with it. Any
service speaking the OpenAI chat-completions format works; the address is the
only thing that decides which one answers.

**Test connection** sends one request and shows the reply or the error.

**Write a summary** sets how often a summary is generated: 1 min, 5 min, 1, 3,
9, 12 or 24 hours.

### What the AI does

| Behaviour | Trigger | Frequency |
| --- | --- | --- |
| Rewords a reminder | Its completion rate over the last 8 settled firings drops to ≤30% or rises to ≥60% | On the stance changing, plus a daily refresh |
| Varies the character's reaction | You answer a reminder | Four alternatives per outcome, refreshed daily, picked at random per firing |
| Says goodnight | 5 minutes before your quiet hours start | Daily, and only if quiet hours are set |
| Writes a summary | The chosen interval elapses | Your interval |

A reminder whose rate sits between 30% and 60% has its coach line deleted and
returns to your own wording.

### What the app does without it

Everything else. Scheduling, delivery, the character, recording outcomes,
reports, streaks. With no model configured, reminders use the wording you typed
and the character uses its built-in lines.

### How it is wired

The AI never sits between a reminder coming due and you seeing it.

```
you answer or ignore a reminder
        ↓
KairoCoach reads the recorded history from SQLite
        ↓
asks your model
        ↓
writes a line into coach_lines / coach_reactions
        ↓
KairoReminderEngine reads that table (held in memory)
        ↓
reminder fires with the coached wording, or yours if there is none
```

Generation happens minutes or hours before the reminder it affects. Every path
into the AI is guarded: a model that is unreachable, slow, misconfigured or
returning nonsense is indistinguishable from one that was never set up.

Turning coaching off deletes every generated line and summary immediately.

### What leaves your machine

Only if you point the address at a host that is not your own. The settings
screen states in red when that is the case.

Sent: the reminder's wording, and counts — how many of the last 8 you completed,
your weekly totals per outcome, your streak.

Never sent: reminder ids, timestamps, occurrence rows, machine or user
identifiers, anything about other applications.

Not exported: the JSON export in Settings → Data excludes your API key, the AI
settings and every generated line and summary.

### Responsibilities

| Package | Owns |
| --- | --- |
| `kairo_scheduler` | When something is due |
| `kairo_workflow_engine` | Whether it may be shown |
| `kairo_reminder_engine` | What a reminder is, and delivering it |
| `kairo_storage` | The only SQL in the project |
| `kairo_ai` | The optional coach and summary writer |
| `kairo_event_bus` | Features talking without knowing each other |
| `kairo_character_engine` | The character rig |
| `kairo_desktop_engine` | Windows, overlays, the native bridge |
| `kairo_design_system` | Colours, spacing, type, theme |
| `kairo_shared_models` | Immutable data everything shares |

`kairo_ai` depends on the others. Nothing depends on `kairo_ai` except the
application wiring it up. See
[ADR-0007](docs/adr/ADR-0007-optional-ai-coach.md).

## Build from source

[FVM](https://fvm.app) with Flutter 3.44.7, pinned in `.fvmrc`. The packages are
a [pub workspace](https://dart.dev/tools/pub/workspaces), so one `pub get` at
the root resolves all of them.

```bash
fvm install
fvm flutter pub get
fvm flutter analyze

cd apps/desktop && fvm flutter run -d macos
```

Code generation — the native platform bridge from its Pigeon schema, and the
database classes from their Drift tables:

```bash
./scripts/generate.sh
```

Run it after changing a table or the bridge schema. Generated files are
committed, so a stale one is a build that disagrees with its source.

Package a DMG:

```bash
./scripts/package-dmg.sh
```

Writes `dist/Kairo-<version>.dmg`, taking the version from
`apps/desktop/pubspec.yaml` unless you pass one. Publishing is separate:

```bash
gh release create v1.0.0 dist/Kairo-1.0.0.dmg --title "Kairo 1.0.0"
```

macOS network access requires `com.apple.security.network.client` in both
entitlements files. Without it AI requests fail in release builds and succeed in
debug.

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
  kairo_ai/                 Optional coaching and summaries
assets/                     Character sheet and application icon
docs/                       Architecture and decision records
scripts/                    Code generation and packaging
```

## Licence

[PolyForm Noncommercial 1.0.0](LICENSE). Copyright © 2026
[Azad Mohamed](https://github.com/azadhmhd).

Read it, run it, fork it, learn from it, contribute to it — any noncommercial
use is free and needs no permission. Selling Kairo or a derivative does need
permission; open an issue.

Kairo is **source-available rather than open source**: the Open Source
Definition does not allow a licence to restrict commercial use.
[ADR-0006](docs/adr/ADR-0006-licence.md) records why.

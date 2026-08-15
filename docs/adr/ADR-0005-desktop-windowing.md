# ADR-0005: Desktop Windowing and the Native Bridge

Status: Accepted

Date: 2026-07-27

## Context

Kairo needs several independent desktop windows: the dashboard, a transparent
window for the character, and reminder popups. Beyond a second window, it needs
window levels, mouse pass-through and transparency — none of which Flutter
exposes on the stable channel.

Three routes were available.

1. `window_manager`, already used for the main window. It controls exactly one
   window and cannot create another.
2. `desktop_multi_window`, a third-party plugin. Version 0.3.0, last published
   roughly nine months ago, and it would own the part of Kairo that most defines
   how the product feels.
3. Native code behind a generated bridge.

Inspection of the pinned Flutter SDK (3.44.7) confirmed the third route uses
only public, non-experimental embedder API:

- `FlutterEngine initWithName:project:` and `runWithEntrypoint:` spawn an
  additional engine on a named Dart entrypoint.
- `FlutterViewController initWithEngine:nibName:bundle:` attaches it to an
  `NSWindow`.
- `FlutterViewController.backgroundColor` accepts `NSColor.clear`, which is what
  a transparent character window requires.

Flutter's own first-party windowing (`RegularWindowController`,
`SatelliteWindowController`) exists in the SDK but is `@internal`, gated behind
`FLUTTER_ENABLED_FEATURE_FLAGS=windowing`, main-channel only, and documented as
unsuitable for production.

## Decision

Kairo implements its own native window host, reached through a bridge generated
by Pigeon.

### One engine per window

Each Kairo window runs its own `FlutterEngine`. The native side owns the window
and its engine; Dart addresses windows by handle.

### Windows do not share Dart state

An engine runs its own isolate with its own heap. **Two Kairo windows are two
separate Dart programs that happen to share a process.** A `Stream` in one is
invisible to the other, so `kairo_event_bus` reaches one window only. Delivering
an event between windows requires the native side to relay it, because the
platform is the only thing both isolates can see.

This is a property of the embedder, not a limitation to be engineered around.
Any design that assumes a process-wide Dart bus is wrong.

### The bridge is generated, not hand-written

The Dart API and the Swift protocol are generated from a single schema at
`packages/kairo_desktop_engine/pigeons/platform_bridge.dart`, using `pigeon`
(published by flutter.dev). Both sides of every signature are checked by a
compiler rather than by discipline. Generated files are committed; neither is
edited by hand.

### No third-party multi-window plugin

`desktop_multi_window` is not adopted. Kairo would be depending on an
infrequently updated package for its most product-defining behaviour, and the
native code it wraps is code Kairo can own outright.

### Windows are addressed by type and instance

`KairoWindowType` describes purpose; `KairoWindowId` identifies one window as a
type plus an optional instance key. Reminder popups can therefore exist several
at a time without the identity scheme changing.

## Consequences

- Windows behave natively, including transparency, levels and pass-through.
- Windows support becomes an implementation of the same generated protocol
  against Win32; no Dart changes.
- Cross-window communication must be designed as a bridge concern from the
  start. A relay is added to the schema in the sprint that first needs it
  (Milestone 2.7), and deliberately not before.
- Kairo carries native code, and with it the cost of maintaining it per
  platform. This is accepted as the price of the product feeling native.
- Building requires a code generation step, `melos run generate`. The repository
  had no code generation before this decision.

## Deferred

*Resolved 2026-08-15: both items below have since been built.*

`kairo_scheduler` is reserved as a package name. Scheduling is not
reminder-specific — daily summaries, database maintenance and future AI
reflection all need it — but nothing schedules anything yet, so the package is
created in the milestone that gives it code.

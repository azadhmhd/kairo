# Kairo Architecture

Kairo is not a reminder app. Kairo is an offline-first desktop companion
platform. Reminders are one feature. AI is one enhancement. The platform is the
product.

## Layers

```
Presentation    Dashboard, settings, reports. Renders and reacts. No rules.
     ↓
Runtime         Starts services, owns their lifecycle, coordinates them.
     ↓
Domain          Reminders, workflows, analytics, character behaviour.
                Pure Dart: no Flutter, no Swift, no UI.
     ↓
Infrastructure  SQLite, AppKit, the file system, native windows.
```

A layer may call downward. It may never call upward, and it may never reach
past the layer beneath it.

## Packages

One responsibility each.

| Package | Owns |
|---|---|
| `kairo_shared_models` | Immutable data. No behaviour. |
| `kairo_storage` | SQLite, repositories, queries. The only code that writes SQL. |
| `kairo_design_system` | Colours, spacing, radius, shadow, type, theme. |
| `kairo_event_bus` | How features reach each other without knowing each other. |
| `kairo_scheduler` | *When* something should happen. Nothing else. |
| `kairo_workflow_engine` | *Whether* it should happen: trigger, conditions, actions. |
| `kairo_reminder_engine` | *What* the reminder is. It does not own scheduling. |
| `kairo_character_engine` | *How* it is presented: behaviour, as a state machine. |
| `kairo_desktop_engine` | *Where* it appears: windows, overlays, the native bridge. |

Packages depend downward on this list, never upward, and never on the
application. Circular dependencies are a bug.

## Startup

```
main()
  ↓ bootstrap()
      Storage          open the database, read settings
      Workflow engine  start listening before anything publishes
      Reminders        seed defaults, put schedules in place
      Desktop shell    shape the main window, open the character window
      Scheduler        start the clock, last
  ↓ runApp()
```

The order is the dependency order, and two steps in it are load-bearing. The
workflow engine listens before anything can publish, because the bus does not
replay — an event published into an empty bus reaches nobody. The scheduler
starts last for the same reason: everything a due reminder has to reach is
already listening by then.

The main window is shaped before the first frame is scheduled, so the user never
sees it resize itself at launch.

## A reminder, end to end

```
Scheduler        time reached
  ↓
Workflow engine  conditions pass?
  ↓
Reminder engine  what to say
  ↓
Event bus        ReminderDueEvent
  ↓
Character engine which behaviour
  ↓
Desktop engine   which window
  ↓
User
```

And the response:

```
User clicks Done
  ↓ Desktop engine
  ↓ Event bus
  ↓ Workflow engine
  ↓ Storage
  ↓ Analytics
  ↓ Dashboard updates
```

Nothing in either chain holds a reference to the thing after it. Any number of
listeners can react to `ReminderDueEvent` — the character, analytics, the
dashboard, a logger, one day an AI — without the reminder code changing.

## Windows

Kairo is a multi-window application: a dashboard, a transparent character
window and reminder overlays. The desktop engine owns all of them through a
Pigeon-generated bridge to native code.

**Each window runs its own `FlutterEngine`, and therefore its own isolate.** Two
Kairo windows are two separate Dart programs that happen to share a process. A
`Stream` in one is invisible to the other, so the event bus reaches one window
only, and delivering an event between windows requires a native relay. This is a
property of the embedder, not something to engineer around. Any design that
assumes a process-wide Dart bus is wrong. See
[ADR-0005](../adr/ADR-0005-desktop-windowing.md).

## The character

`kairo_character_engine` is a rig and nothing more: hand it a view, an
expression, a pose and an animation and it draws exactly that. It decides
nothing.

What the character *does* is decided in the application, by `CharacterPresence`
in the main isolate: it watches the event bus, tells the character window what
to say over the native relay, and turns a click on the desktop back into a
recorded answer. The character window itself has no bus, no database and no
providers — it draws and reports which button was pressed.

Behaviour as a state machine inside the engine is Milestone 4. Future AI changes
the dialogue, never the transitions.

## Why AI comes last

The application is finished first. Then AI observes it — reminder history,
analytics, workflow history, settings — and rewords what the application had
already decided to say.

> Without AI: *Time to drink water.*
>
> With AI: *Nice work — that's four reminders done today. One more glass keeps
> the streak going.*

The reminder still came from the reminder engine.

**The golden rule: business logic must never depend on AI. AI may depend on
business logic.** This is what guarantees Kairo works perfectly offline and with
no model installed.

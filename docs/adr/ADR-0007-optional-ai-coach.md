# ADR-0007: Optional AI Coach

Status: Accepted

Date: 2026-08-16

## Context

Kairo repeats the same sentence every twenty minutes forever.

A reminder the user has ignored eleven times is not improved by a twelfth
identical delivery. A habit the user has kept for a week is never acknowledged.

ADR-0001 states that Kairo works offline, keeps everything local, and uploads
nothing. Version 1 excludes AI. Those principles are not in question here.

## Decision

Kairo gains an optional coach, in a new package `kairo_ai`.

The coach reads recorded history, asks a model for better wording, and writes
that wording into a `coach_lines` table. The reminder engine reads that table
and uses a line if one is there.

Direction of dependency:

Coach

↓

Storage

↓

Reminder Engine

The reminder engine does not depend on `kairo_ai`. No request is made on the
path between a reminder coming due and the user seeing it.

### Off by default, local by default

Coaching is off until the user enables it. The default address is
`http://localhost:11434/v1`, a model running on the user's own machine. No model
is chosen for them.

With coaching off, Kairo behaves exactly as it did before this ADR.

### No AI client dependency

A chat completion is one POST with a JSON body. `dart:io` and `dart:convert`
already do this. A client package would be a dependency tree Kairo publishes,
reviews and ships for thirty lines of work.

The OpenAI chat-completions format is used because Ollama, LM Studio,
llama.cpp and the hosted services all accept it. The address is the only thing
that decides which one answers.

### Failure is silence

Every path into the coach is guarded. An unreachable, misconfigured, slow or
nonsense-producing model is indistinguishable from one that was never set up:
the reminder arrives on time, in the user's own words.

### The user's wording is never overwritten

`reminder_definitions.label` is the user's. Coach lines live in their own table
and stand in front of it. Dropping a coach line restores the user's wording
exactly.

## Consequences

- Kairo can now make an outbound network request, which it never could before.
  `com.apple.security.network.client` is required on macOS.
- An API key is stored in the local database in plaintext. Acceptable while that
  file never leaves the machine; revisit when Kairo grows a sync.
- Data export excludes the AI settings and the coach lines.
- Sending history to a hosted service is possible and is the user's decision.
  The settings screen states plainly, in red, when the configured address is not
  on this machine.
- ADR-0001's offline-first and privacy-first principles hold: nothing is
  mandatory, nothing is enabled without consent, and the default configuration
  makes no network request of any kind.

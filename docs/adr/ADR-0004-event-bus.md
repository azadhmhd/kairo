# ADR-0004: Event-Driven Architecture

Status: Accepted

Date: 2026-07-22

## Context

Features should remain loosely coupled.

Reminder logic should not directly depend on the character system.

## Decision

Kairo adopts an internal event-driven architecture.

Example:

Reminder Due

↓

Event Bus

↓

Character Engine

↓

Notification

↓

Analytics

↓

History

Features communicate through events rather than direct method calls.

## Consequences

- Better modularity
- Easier testing
- Future AI integration without modifying existing modules

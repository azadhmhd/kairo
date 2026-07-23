# ADR-0003: Local Storage

Status: Accepted

Date: 2026-07-22

## Context

Kairo is designed as an offline-first desktop application.

## Decision

SQLite is the only storage engine for Version 1.

Drift will be used as the ORM.

No cloud database.

No PostgreSQL.

No synchronization service.

Future AI memory may introduce a dedicated local vector database without replacing SQLite.

## Consequences

- Simple installation
- Offline support
- Excellent performance
- Zero infrastructure requirements

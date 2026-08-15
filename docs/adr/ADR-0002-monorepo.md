# ADR-0002: Monorepo Structure

Status: Accepted

Date: 2026-07-22

## Context

Kairo consists of multiple reusable modules that should remain independent.

## Decision

The project will use a Flutter monorepo managed by Melos.

Repository structure:

- apps/
- packages/
- assets/
- docs/
- scripts/ — never used; removed 2026-08-15
- tools/ — never used; removed 2026-08-15

Packages must be reusable and independently testable.

Business logic must not depend on Flutter UI.

## Consequences

- Faster development
- Better code reuse
- Easier testing
- Cleaner separation of responsibilities

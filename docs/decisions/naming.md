# Naming

| | |
|---|---|
| Project | Kairo |
| Repository | `kairo` |
| Application | Kairo |
| Bundle identifier | `com.kairo.desktop` |
| Package prefix | `kairo_` |

## Rules

Packages are named `kairo_<responsibility>`, and the responsibility is the
noun the architecture uses for it. A package that runs something is an
`_engine`: `kairo_workflow_engine`, not `kairo_workflow`.

Public types are prefixed `Kairo` — `KairoEventBus`, `KairoWindowId` — so a
call site reads unambiguously in an application that also imports Flutter,
Drift and Riverpod. Types private to a package are not.

The current package list lives in
[the architecture overview](../architecture/overview.md#packages), which is
the one place it is written down.

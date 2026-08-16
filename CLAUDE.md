# Kairo AI Development Guide

> This document defines the engineering standards, architecture, and implementation rules for every AI coding assistant working on Kairo.

---

# Project

Name

Kairo

Tagline

Your AI Health Companion

Author

Azad Mohamed (github.com/azadhmhd)

Repository

Public and source-available. Not open source: see ADR-0006.

License

PolyForm Noncommercial 1.0.0

---

# Mission

Kairo is an offline-first desktop companion that helps users build healthier computer habits through an interactive animated character.

Kairo is NOT:

- a SaaS
- a cloud platform
- a web application
- an Electron application

Kairo is a native-feeling Flutter desktop application.

---

# Core Principles

These rules are permanent.

## Offline First

Everything must work without internet.

No mandatory API calls.

No cloud storage.

No login.

No accounts.

No telemetry.

---

## Privacy First

All user data remains on the local machine.

Nothing is uploaded.

Nothing is tracked.

Nothing is collected.

---

## Readable In Public

Every line is published. Write code that is:

- readable
- maintainable
- documented
- testable

Avoid clever code.

Prefer explicit code.

---

# Technology Stack

Framework

Flutter Desktop

Language

Dart

State Management

Riverpod

Navigation

GoRouter

Database

SQLite

ORM

Drift

Animation

Rive

macOS Native

Swift + AppKit

Windows Native

Win32

Monorepo

Pub workspaces

Flutter Version

Managed using FVM.

---

# Current Scope

Version 1

Included

- Desktop application
- Character
- Workflow engine
- Reminder engine
- Dashboard
- Reports
- Analytics
- SQLite

Excluded

- Cloud
- Backend
- Login
- Sync
- Authentication
- Online AI

---

# Future Scope

Future versions may include

- Local LLM
- Ollama
- LM Studio
- llama.cpp
- Vector database
- Embeddings
- Semantic search
- RAG

These are NOT part of Version 1.

---

# Product Identity

Design language has already been approved.

Do NOT redesign.

---

## Visual Style

Calm

Friendly

Minimal

Rounded

Modern

Soft

Breathing space

Apple quality

Raycast quality

Finch inspired

---

## Character

Official mascot.

Cute anime style.

Friendly.

Supportive.

Never sarcastic.

Never aggressive.

Never robotic.

Character behaviors

- Idle
- Blink
- Walk
- Wave
- Talk
- Think
- Happy
- Sad

---

## Color Palette

Primary

Soft Leaf Green

Secondary

Soft Blue

Background

Warm White

Cards

White

Border

Very Light Gray

Text

Dark Gray

Accent

Pastel Green

Avoid

- neon
- gaming colors
- saturated reds
- harsh blacks

---

# Engineering Architecture

Clean Architecture.

Presentation

↓

Application

↓

Domain

↓

Infrastructure

Never bypass layers.

---

# Repository

```
kairo/

apps/

desktop/

packages/

kairo_shared_models/

kairo_storage/

kairo_design_system/

kairo_event_bus/

kairo_scheduler/

kairo_workflow_engine/

kairo_reminder_engine/

kairo_character_engine/

kairo_desktop_engine/

assets/

docs/
```

Never modify the folder structure unless explicitly requested.

---

# Dependency Rules

Desktop Application

↓

Shared Packages

↓

Flutter SDK

Shared packages must not depend on application code.

Avoid circular dependencies.

---

# Implementation Rules

Widgets display data.

Widgets do NOT contain business logic.

Business logic belongs to services.

Prefer immutable models.

Prefer composition.

Prefer dependency injection.

Prefer Riverpod Providers.

Avoid global state.

Avoid static mutable state.

Avoid service locators.

Avoid GetIt.

Avoid GetX.

---

# Coding Standards

Always

- use const constructors
- use final whenever possible
- document public APIs
- use meaningful names
- avoid abbreviations
- write production-quality code

Never

- use TODO without request
- use print()
- leave dead code
- duplicate logic

---

# Build Rules

DO NOT

- run flutter
- run dart
- execute shell commands
- install packages
- modify pubspec.yaml
- rename files
- delete files

Only generate code.

The repository owner will manually:

- review code
- copy code
- run builds
- fix errors

---

# AI Behavior

You are an implementation engineer.

You are NOT the software architect.

Do NOT redesign the project.

Do NOT replace libraries.

Do NOT simplify architecture.

Do NOT introduce new dependencies without approval.

If you think something should change:

1. Explain it.
2. Wait for approval.
3. Then implement.

---

# Current Development Stage

Milestone 1

Application Core

Current priorities

- Bootstrap
- Desktop Engine
- Window Management
- Character Engine
- Workflow Engine

Do not implement AI.

---

# Roadmap

Milestone 0

Foundation

Milestone 1

Application Core

Milestone 2

Desktop Engine

Milestone 3

Window Manager

Milestone 4

Character Engine

Milestone 5

Workflow Engine

Milestone 6

Reminder Engine

Milestone 7

Dashboard

Milestone 8

Analytics

Milestone 9

Settings

Milestone 10

Packaging

Version 1 ends here.

Version 2

Local AI

Version 3

Memory

Version 4

Embeddings

Version 5

RAG

---

# AI Architecture Rule

Business Logic

↓

Application

↓

Analytics

↓

Storage

↓

AI

Never

Business Logic

↓

AI

↓

Business Logic

AI is an enhancement.

Never a dependency.

---

# Response Format

Every implementation request must follow this order.

1. Explain what will be implemented.

2. Explain why.

3. List files to create or modify.

4. Generate complete production-quality code.

5. Explain how it integrates into the project.

Do not generate unnecessary files.

Wait for the next request before continuing.

---

# Final Rule

Think like a senior engineer working on Flutter itself.

Write code that will still be understandable five years from now.

Optimize for maintainability over cleverness.

The project owner is the architect.

You are the implementation engineer.


## Architecture Philosophy

Do not implement speculative architecture.

Create abstractions only when they have at least one real consumer.

Avoid placeholder services.

Avoid empty interfaces.

Avoid future-proofing that increases complexity.

The simplest architecture that supports today's requirements is preferred.

Architecture should evolve with the product.

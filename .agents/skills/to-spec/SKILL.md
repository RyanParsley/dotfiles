---
name: to-spec
description: Turn a settled conversation or plan into a durable local Markdown specification. Use when formalizing requirements, user stories, implementation decisions, and testing decisions before work begins. Keep the local specification canonical and mirror it to an issue tracker only when requested or required by project policy.
disable-model-invocation: true
---

# To spec

Turn settled conversation context and codebase understanding into a specification. Do not interview the user. Synthesize what is already known and record it locally.

Local Markdown is the canonical specification. An issue tracker is an optional mirror, not the source of truth.

## Choose the note

Choose the nearest existing Markdown convention.

- In a notes vault, use `Projects/<work-name>/<work-name>-spec.md`.
- In a code repository, use its existing `docs/`, `plans/`, or `notes/` directory.
- If no convention exists, use `notes/<work-name>/spec.md` in the current workspace.
- Update an existing specification when it already covers the work. Do not create a competing document.

Create the local specification before any optional tracker publication. Mark it `draft` until the user confirms the test seams and requirements.

## Process

1. Explore the relevant codebase when needed. Use the project's glossary and respect ADRs in the area being changed.
2. Choose or create the local specification note. Preserve existing content when updating it.
3. Sketch the highest practical test seams. Prefer existing seams and use the fewest seams that prove the external behavior.
4. Record the specification using the template below.
5. Present the proposed test seams and unresolved requirements to the user. Update the local note after each meaningful decision.
6. Mark the note `approved` only after the user confirms the seams and requirements.
7. Mirror the approved specification to a tracker only when requested or required by project policy. Record the tracker URL in the local note.

## Specification template

```markdown
---
title: <work name> specification
date: <YYYY-MM-DD>
status: draft
kind: specification
source: <conversation, note, or issue>
tracker: none
---

# <Work name> specification

## Problem statement

<The problem from the user's perspective.>

## Solution

<The behavior that solves the problem from the user's perspective.>

## User stories

1. As an <actor>, I want <feature>, so that <benefit>.

## Implementation decisions

- <Decision, constraint, contract, or domain rule.>

## Testing decisions

- <External behavior and the seam that proves it.>

## Out of scope

- <Excluded behavior.>

## Open questions

- <Requirement or decision that is not settled.>

## Resolution log

- <Date>. <Decision>. <Evidence or conversation reference.>
```

Avoid specific file paths and code snippets when they would become stale. Keep a prototype's type shape, state machine, or schema only when it preserves a decision more precisely than prose.

## Relationship to other workflows

Use `wayfinder` when the destination or scope is still uncertain. Use `to-spec` when the requirements are settled enough to write a specification. Use `to-tickets` after the destination is clear and the specification needs implementation slices. All three workflows write local Markdown first.

## Gotchas

- Do not publish a specification before recording it locally.
- Do not turn unresolved requirements into confident implementation decisions.
- Do not create a second specification when an existing project note owns the work.
- Do not mark a specification approved until the test seams and open questions are explicit.

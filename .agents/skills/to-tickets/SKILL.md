---
name: to-tickets
description: Break a plan, specification, or conversation into tracer-bullet implementation tickets and record the approved breakdown in local Markdown. Use when turning work into tickets, a roadmap, or an implementation queue. Keep the Markdown record canonical and mirror it to an issue tracker only when requested or required by project policy.
disable-model-invocation: true
---

# To tickets

Break a plan, specification, or conversation into tracer-bullet tickets. Each ticket states what it delivers, how it can be verified, and which tickets block it.

Local Markdown is the canonical record. An issue tracker is an optional mirror, not the source of truth.

## Choose the note

Choose the nearest existing Markdown convention before drafting tickets.

- In a notes vault, use `Projects/<work-name>/tickets.md`.
- In a code repository, use its existing `docs/`, `plans/`, or `notes/` directory.
- If no convention exists, use `notes/<work-name>/tickets.md` in the current workspace.
- Update an existing roadmap or planning note when it already covers the work. Do not create a competing note.
- Keep the canonical note out of `/tmp`.

Create or update the local note before asking the user to approve the breakdown. Mark an unapproved breakdown `draft` and an approved breakdown `approved` in frontmatter.

## Process

### 1. Gather context

Work from the conversation context. If the user passes a specification path, issue number, URL, or local note, read its full body and relevant comments before drafting.

### 2. Create or update the local note

Resolve the note location using the rules above. Preserve existing content when updating a note. Start a new note with:

```yaml
---
title: <work name> tickets
date: <YYYY-MM-DD>
status: draft
kind: tickets
source: <conversation, note, specification, or issue>
tracker: none
---
```

Add a short context section and link the source material. Record decisions and open questions as they arise.

### 3. Explore when needed

If the current state is unclear, inspect the relevant codebase. Use the project's glossary and respect ADRs in the area being changed. Record prefactoring only when it has a concrete purpose and its own verification.

### 4. Draft vertical slices

Break the work into tracer-bullet tickets.

- Each slice cuts a narrow but complete path through every required layer.
- A completed slice is demoable or verifiable on its own.
- Each slice fits in one fresh context window.
- Prefactoring comes before the slice that depends on it.
- Each ticket states its blocking tickets. A ticket with no blockers can start immediately.

Wide refactors are the exception. Sequence them as expand, migrate, and contract. Give each migration batch its own ticket and verification. Make the contract ticket depend on every migration batch. If a batch cannot stay green alone, record the integration branch and final verification ticket in the note.

### 5. Record the draft

Write the proposed breakdown into the local note before presenting it. Include:

- The problem and desired outcome.
- The ticket titles.
- What each ticket delivers.
- Acceptance criteria.
- Blocking tickets.
- Open questions and assumptions.
- The current frontier.

Use one section per ticket. Keep implementation paths and code snippets out unless a prototype made them necessary to preserve a decision.

### 6. Ask for approval

Present the proposed breakdown as a numbered list. For each ticket, show its title, blockers, and delivered behavior.

Ask whether the granularity, dependencies, and ticket boundaries are correct. Update the local note after each meaningful decision. Do not publish or implement while the breakdown remains unapproved.

### 7. Mark the note approved

After approval, change the note status to `approved`. Record the approval date and the agreed frontier. The local note is complete even when no external tracker is available.

### 8. Mirror to a tracker when requested

Publish tickets externally only when the user asks or project policy requires it. Publish from the approved local note in dependency order. Copy its title, acceptance criteria, and blockers. Record tracker URLs beside the matching local ticket.

If publication fails, keep the local note approved and record the failure. Do not discard or rewrite the local plan to fit the tracker.

### 9. Keep the note current

When a ticket starts, set its local status to `in-progress` and record `claimed_by` if multiple agents may work on the queue. When it finishes, record the result, verification evidence, and any new blocker.

Work the frontier. A ticket is on the frontier when every blocking ticket is complete. Use `/implement` for one ticket at a time and update the note after each ticket.

## Local note template

```markdown
---
title: <work name> tickets
date: <YYYY-MM-DD>
status: draft
kind: tickets
source: <source reference>
tracker: none
---

# <Work name> tickets

<One paragraph describing the outcome.>

## Decisions

- <Decision and its date.>

## Frontier

- <Ticket title> because <all blockers are complete or none exist>.

## <Ticket title>

**What to build.** <The end-to-end behavior from the user's perspective.>

**Blocked by.** <Ticket titles or `None`.>

**Acceptance criteria.**

- [ ] <Criterion>
- [ ] <Criterion>

**Verification.** <The command, scenario, or evidence that proves the ticket.>

**Status.** <draft, approved, in-progress, complete, or blocked>

## Open questions

- <Question that must be answered before a ticket can proceed.>

## Resolution log

- <Date>. <Ticket>. <Result and evidence link.>
```

## Relationship to wayfinder

Use `to-tickets` when the destination is clear and the work can be expressed as implementation slices. Use `wayfinder` when the destination, scope, or route still contains decisions that must be resolved first. Both skills write local Markdown first.

## Gotchas

- Do not make tracker publication a prerequisite for capturing the local plan.
- Do not create a second note when an existing roadmap already covers the work.
- Do not mark a ticket complete without recording verification evidence.
- Do not use a tracker issue number as the only reference to a decision or dependency.
- Do not turn unresolved product or architecture questions into implementation tickets. Use `wayfinder` or `/grilling` first.

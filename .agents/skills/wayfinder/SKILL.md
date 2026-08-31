---
name: wayfinder
description: Plan a large or uncertain effort as a local Markdown roadmap and dependency map, then resolve one decision ticket at a time. Use when work spans sessions, has unresolved architecture or product questions, or needs a durable roadmap. Keep Markdown canonical and mirror it to an issue tracker only when requested or required by project policy.
disable-model-invocation: true
---

# Wayfinder

A loose idea has arrived. It is too large or uncertain for one agent session, and the route to the destination is not clear. Wayfinding makes that route explicit without pretending that unanswered decisions are implementation tasks.

Local Markdown is the canonical record. The roadmap, decision tickets, resolutions, and evidence links must exist locally before any optional tracker mirror is created.

## Choose the roadmap location

Choose the nearest existing Markdown convention.

- In a notes vault, use `Projects/<work-name>/wayfinding-map.md` and a sibling `tickets/` directory.
- In a code repository, use its existing `docs/`, `plans/`, or `notes/` directory.
- If no convention exists, use `notes/<work-name>/wayfinding-map.md` in the current workspace.
- Update an existing roadmap when it already covers the effort. Do not create a competing map.
- Keep the canonical roadmap and tickets out of `/tmp`.

## Plan, do not implement

Wayfinder is planning by default. Each ticket resolves one decision or investigation. The map is complete when the route is clear and implementation can proceed without unresolved decisions. Do not implement the destination while charting the map.

## The local map

The map is one local Markdown file. Its tickets are sibling Markdown files in a `tickets/` directory. The map is the canonical artifact.

The map is an index, not a store. It lists decisions and links to the tickets that hold their detail. A decision lives in one ticket, so the map summarizes it instead of duplicating it.

Dependencies live in each ticket's `depends_on` frontmatter and `Blocked by` section. A ticket is unblocked when every dependency has `status: complete`. The frontier is the set of open, unblocked, unclaimed tickets.

Load the map at low resolution once per session. Read a ticket in full only when you select it or need its evidence.

```markdown
---
title: <work name> wayfinding map
date: <YYYY-MM-DD>
status: draft
kind: wayfinding-map
tracker: none
---

# <Work name> wayfinding map

## Destination

<What reaching the end of this map looks like.>

## Notes

<Domain terms, relevant skills, standing preferences, and constraints.>

## Decisions so far

- [<closed ticket title>](tickets/<ticket>.md) - <one-line summary>

## Not yet specified

- <In-scope question that is not precise enough to become a ticket.>

## Out of scope

- <Work deliberately excluded from this destination.>

## Tickets

- [<open ticket title>](tickets/<ticket>.md)
```

## Local tickets

Each ticket is a local Markdown file. Its filename is not its identity. The title and map link are the identity. Size the question to one agent session.

```markdown
---
title: <ticket title>
date: <YYYY-MM-DD>
status: open
kind: wayfinding-ticket
type: research
depends_on: []
map: ../wayfinding-map.md
tracker: none
---

# <Ticket title>

## Question

<The decision or investigation this ticket resolves.>

## Exit predicate

<The evidence that closes this ticket.>

## Resolution

<Filled when complete.>
```

Each ticket's `type` is one of `research`, `prototype`, `grilling`, or `task`.

- `research` is AFK. Read documentation, APIs, or local knowledge bases and record a cited Markdown summary.
- `prototype` is HITL. Build a cheap artifact that lets the human choose between behaviors or designs.
- `grilling` is HITL. Resolve a product, domain, or preference question one question at a time.
- `task` may be HITL or AFK. Complete work that must happen before a decision can be made and record the resulting facts.

Claim a ticket by setting `status: in-progress`, `claimed_by`, and `claimed_at` before work. If another session has claimed it, do not work it without resolving the conflict.

Record the answer in the ticket's `Resolution` section. Link evidence files, commits, prototypes, and external references from the ticket instead of pasting large artifacts into the map.

## Optional tracker mirror

Mirror the approved local roadmap to an issue tracker only when the user asks or project policy requires it. Create the map first, then the tickets, then dependency links. Put tracker URLs beside local Markdown links.

If the tracker is unavailable, continue with the local Markdown roadmap and record the failed mirror attempt. Never make tracker access a prerequisite for capturing work notes.

## Fog of war

The map is deliberately incomplete. The fog contains questions that are in scope but not precise enough to become tickets yet.

Ticket a question when it is precise enough to investigate, even if it is blocked. Keep it in `Not yet specified` when you cannot state the question precisely. Do not pre-slice the fog.

Work beyond the destination is out of scope. Record it in `Out of scope` instead of turning it into fog.

## Chart the map

1. Create or update the local map with `status: draft` before the destination is fully settled. Record the current idea, known constraints, and open questions.
2. Run `/grilling` and `/domain-modeling` to pin down the destination, domain terms, and scope. Record each resolved decision in the map or a ticket.
3. Explore breadth-first and identify decisions precise enough to ticket. If no fog remains and the work fits one session, stop without creating a map.
4. Create the local tickets, then add their `depends_on` links. Link every ticket from the local map.
5. Record the draft frontier and present it to the user. Update the map after each meaningful decision.
6. Mark the map `approved` only after the user confirms the destination and frontier.
7. Mirror the approved map only when requested. Record any tracker URLs locally.
8. Stop. Charting the map is one session's work. Do not resolve tickets in the same charting pass.

## Work through the map

1. Load the local map. Do not start by reading every ticket.
2. Choose the user's named ticket or the first frontier ticket. Claim it in local frontmatter before work.
3. Resolve the ticket. Read related ticket files and invoke the skills named in `Notes`. Use `/grilling` and `/domain-modeling` when the decision is unclear.
4. Record the resolution locally. Set the ticket to `status: complete`, fill `Resolution`, and append a link and one-line summary under `Decisions so far`.
5. Update the map. Add newly precise tickets, wire dependencies, graduate fog into tickets, and mark invalid work `out-of-scope`.
6. Mirror the resolution only when requested. Copy the local resolution to the tracker and record the URL beside the local ticket.

Never resolve more than one ticket per session.

## Relationship to to-tickets and to-spec

Use `wayfinder` when the destination or route is uncertain and the work needs decision tickets. Use `to-tickets` when the destination is clear and the next step is to create implementation slices. Use `to-spec` when the requirements are settled enough to write a complete specification. All three workflows write local Markdown before optional external publication.

## Gotchas

- Do not make issue-tracker access a prerequisite for recording a roadmap.
- Do not use a tracker number as the only identity for a map, ticket, or decision.
- Do not put resolutions only in chat. Write them into the local ticket and map.
- Do not create a new map when an existing project note already owns the roadmap.
- Do not resolve blocked tickets by guessing. Record the blocker or sharpen the question through grilling.

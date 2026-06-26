---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

## When NOT to Grill

- User asks for a quick opinion or sanity check — give a direct answer instead
- User says "just tell me what you think" — they want analysis, not interrogation
- The plan is trivial (one file change, obvious fix) — skip grilling and proceed

## Gotchas

- **Ask one question at a time.** Dumping a list of questions kills the interview feel and overwhelms the user. One question, wait for the answer, then continue.
- **Provide your recommended answer with each question.** The goal is shared understanding, not a quiz — your recommendation gives the user something concrete to react to.

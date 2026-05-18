---
name: zoom-out
description: Tell the agent to zoom out and give broader context or a higher-level perspective. Use when you're unfamiliar with a section of code or need to understand how it fits into the bigger picture.
---

I don't know this area of code well. Go up a layer of abstraction. Give me a map of all the relevant modules and callers, using the project's domain glossary vocabulary.

## Gotchas

- If no `CONTEXT.md` or domain glossary exists, use the code's own naming — don't invent terminology
- Don't zoom out when the user needs line-level detail (fixing a specific bug, reading a function)
- Stop at the first layer that gives a complete picture — don't keep zooming out to the entire repo unless asked

---
name: skill-creator
description: Create well-formed Agent Skills following the agentskills.io specification and best practices. Use when creating new skills, refactoring existing skills, or extracting reusable patterns from completed tasks into portable skill directories.
---

# Skill Creator

You are creating an Agent Skill — a portable folder of instructions that extends an AI agent's capabilities. This skill grounds you in the official specification and best practices.

## Ground Truth

Before creating any skill, fetch the current specification and best practices. The format is early and evolving:

- https://agentskills.io/specification
- https://agentskills.io/skill-creation/best-practices
- https://agentskills.io/skill-creation/optimizing-descriptions

Do not rely on cached knowledge of the spec — always re-read.

## Directory Structure

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation (loaded on demand)
├── assets/           # Optional: templates, resources
└── ...               # Any additional files
```

The directory name **must match** the `name` field in SKILL.md frontmatter.

## SKILL.md Structure

### Frontmatter (required fields)

```yaml
---
name: skill-name          # lowercase, hyphens, 1-64 chars, no leading/trailing/consecutive hyphens
description: What it does and when to use it.  # 1-1024 chars, imperative phrasing
---
```

### Description Guidelines

The description carries the entire burden of triggering. Follow these rules:

1. **Use imperative phrasing**: "Use when..." not "This skill does..."
2. **Focus on user intent**: What the user is trying to achieve, not internal mechanics
3. **Be pushy**: List contexts where the skill applies, including cases where the user doesn't name the domain directly
4. **Keep it concise**: A few sentences to a short paragraph

Good example:
```yaml
description: Extracts text and tables from PDF files, fills PDF forms, and merges multiple PDFs. Use when working with PDF documents or when the user mentions PDFs, forms, or document extraction.
```

Poor example:
```yaml
description: Helps with PDFs.
```

### Body Content

- Keep SKILL.md under 500 lines and ~5000 tokens
- Use step-by-step instructions, examples, gotchas
- Move detailed reference material to `references/` files
- Tell the agent *when* to load each reference file (progressive disclosure)

## Creation Process

### 1. Define the Scope

A skill should encapsulate a **coherent unit of work** — like a well-designed function:
- Too narrow: forces multiple skills to load for one task
- Too broad: hard to activate precisely

Ask: "What is the one thing this skill does?"

### 2. Start from Real Expertise

Extract from actual work, not generic best practices:
- Steps that worked in practice
- Corrections the user made during execution
- Input/output formats used
- Project-specific facts the agent wouldn't know

### 3. Write the Description First

The description determines whether the skill ever activates. Write it before the body. Test it against these questions:
- Would this trigger on a casual prompt? ("can you roll a d20" vs "roll dice")
- Would it trigger on a multi-step prompt where this skill is one piece?
- Would it *not* trigger on near-miss prompts that share keywords but need something different?

### 4. Write the Body

Apply these principles:

**Add what the agent lacks, omit what it knows.** Don't explain what a PDF is. Jump straight to the non-obvious parts.

**Favor procedures over declarations.** Teach *how to approach* a class of problems, not *what to produce* for one instance.

**Provide defaults, not menus.** Pick a default approach. Mention alternatives briefly as escape hatches.

**Match specificity to fragility.** Be prescriptive when operations are fragile; give freedom when multiple approaches are valid.

### 5. Structure for Progressive Disclosure

- Core instructions in SKILL.md (what the agent needs on every run)
- Reference material in `references/` (loaded on demand)
- Scripts in `scripts/` (bundled logic the agent would otherwise reinvent)

Tell the agent *when* to load each file:
```markdown
Read `references/api-errors.md` if the API returns a non-200 status code.
```

### 6. Include Gotchas

The highest-value content is a list of gotchas — environment-specific facts that defy reasonable assumptions:

```markdown
## Gotchas

- The `users` table uses soft deletes. Queries must include
  `WHERE deleted_at IS NULL`.
- The `/health` endpoint returns 200 even if the database is down.
  Use `/ready` for full service health.
```

### 7. Validate

Check against the specification:
- `name` matches directory name, follows naming rules
- `description` is non-empty, under 1024 chars
- Frontmatter is valid YAML
- File references use relative paths from skill root
- SKILL.md is under 500 lines

## Anti-Patterns to Avoid

1. **Vague procedures**: "handle errors appropriately" — says nothing actionable
2. **Exhaustive documentation**: Covering every edge case makes the skill hard to use
3. **Menus of options**: "You can use A, B, C, or D..." — pick a default
4. **Reinventing the wheel**: If the agent would independently write the same logic, bundle it as a script
5. **Deep reference chains**: Keep file references one level deep from SKILL.md
6. **Project-specific names in general skills**: Don't mention "Cerebro" in a general Rust skill

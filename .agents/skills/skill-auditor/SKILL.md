---
name: skill-auditor
description: Audit existing Agent Skills for spec compliance, best-practice adherence, and description quality. Use when reviewing skills for correctness, identifying improvements, or validating skills before shipping. Always ground yourself in the official agentskills.io docs first — the standard is early and volatile.
---

# Skill Auditor

You are auditing Agent Skills for correctness and quality. **Before auditing, always re-read the official documentation** — the specification and best practices are evolving rapidly.

## Ground Truth (Read First)

Fetch these pages before beginning any audit:

- https://agentskills.io/specification
- https://agentskills.io/skill-creation/best-practices
- https://agentskills.io/skill-creation/optimizing-descriptions

Do not rely on cached knowledge. The format is early and the rules change.

## Audit Process

### Phase 1: Spec Compliance (Hard Rules)

These are violations of the specification. They will cause parsing failures or rejections.

| Check | Rule | How to Verify |
|-------|------|---------------|
| Directory name | Must match `name` field exactly | Compare directory name to frontmatter `name` |
| Name format | Lowercase `a-z`, hyphens only, 1-64 chars, no leading/trailing/consecutive hyphens | Regex: `^[a-z][a-z0-9-]*[a-z0-9]$` or `^[a-z]$` |
| Description | Non-empty, 1-1024 characters | Count characters, check non-empty |
| Frontmatter | Valid YAML between `---` delimiters | Parse YAML, check for errors |
| File structure | SKILL.md exists at skill root | File exists check |
| File references | Relative paths from skill root, one level deep | Scan for `../` or deep paths |

### Phase 2: Best Practice Adherence (Soft Rules)

These affect quality but won't cause hard failures. Score each as PASS, FLAG, or FAIL.

| Check | What to Look For |
|-------|-----------------|
| **Context budget** | SKILL.md under 500 lines and ~5000 tokens. Reference material moved to `references/` |
| **Progressive disclosure** | Large skills use `references/` with explicit "when to load" instructions |
| **Gotchas section** | Non-obvious edge cases captured as concrete gotchas, not vague advice |
| **Procedures over declarations** | Teaches *how to approach* problems, not *what to produce* for one instance |
| **Defaults, not menus** | Clear default approach with escape hatches, not equal-option lists |
| **Specificity calibrated** | Prescriptive for fragile operations, flexible for choices with multiple valid approaches |
| **No repetition** | Agent's existing knowledge not re-explained (no "what is a PDF" sections) |
| **Coherent scope** | One unit of work, not trying to do too much or too little |
| **Description quality** | Imperative phrasing ("Use when..."), user-intent focused, specific keywords |
| **No project bleed** | General skills don't mention specific project names (e.g., "Cerebro" in a Rust skill) |

### Phase 3: Description Trigger Analysis

Evaluate whether the description will activate correctly:

1. **Should-trigger test**: Generate 3-5 realistic prompts that *should* activate this skill. Would the description catch them?
2. **Should-not-trigger test**: Generate 2-3 near-miss prompts that share keywords but need something different. Would the description incorrectly fire?
3. **Phrasing check**: Does it use imperative phrasing ("Use when...") rather than declarative ("This skill does...")?

## Audit Report Format

Produce a structured report for each skill audited:

```markdown
# Audit: <skill-name>

## Spec Compliance

| Check | Status | Notes |
|-------|--------|-------|
| Directory name matches `name` | PASS/FAIL | ... |
| Name format valid | PASS/FAIL | ... |
| Description non-empty, <1024 chars | PASS/FAIL | ... |
| Frontmatter valid YAML | PASS/FAIL | ... |
| SKILL.md exists | PASS/FAIL | ... |
| File references correct | PASS/FAIL | ... |

## Best Practices

| Check | Verdict | Notes |
|-------|---------|-------|
| Context budget (<500 lines) | PASS/FLAG/FAIL | X lines |
| Progressive disclosure | PASS/FLAG/FAIL | ... |
| Gotchas section | PASS/FLAG/FAIL | ... |
| Procedures over declarations | PASS/FLAG/FAIL | ... |
| Defaults, not menus | PASS/FLAG/FAIL | ... |
| Specificity calibrated | PASS/FLAG/FAIL | ... |
| No repetition of agent knowledge | PASS/FLAG/FAIL | ... |
| Coherent scope | PASS/FLAG/FAIL | ... |
| Description quality | PASS/FLAG/FAIL | ... |
| No project bleed | PASS/FLAG/FAIL | ... |

## Description Trigger Analysis

**Should-trigger prompts:**
- "..." → Would trigger: Yes/No
- "..." → Would trigger: Yes/No

**Should-not-trigger prompts:**
- "..." → Would trigger: Yes/No (false positive risk)

## Recommendations

1. [Highest priority fix]
2. [Next fix]
3. ...
```

## Verdict Definitions

- **PASS**: Meets the requirement well. No changes needed.
- **FLAG**: Minor issue or improvement opportunity. Not blocking but worth addressing.
- **FAIL**: Violates the requirement. Should be fixed before shipping.

## Gotchas

- **OpenCode recognizes `license`, `compatibility`, and `metadata` as valid optional frontmatter fields.** The agentskills.io spec doesn't list them, but OpenCode's implementation explicitly supports them. Don't flag them as violations.
- **The spec is early and volatile.** Rules change without announcement. Always re-fetch the live docs before auditing — cached knowledge goes stale fast.
- **`{baseDir}` is not substituted by OpenCode.** If a skill uses `{baseDir}` in bash commands, the agent must infer the path from the "Base directory" context injected at skill load time. Flag it as fragile, not broken.
- **Directory name must match `name` field exactly** — a common mismatch when a skill is renamed after creation.
- **A description that lists correct keywords but buries them in vague prose will still miss triggers.** Test with realistic casual prompts, not just formal ones.

## Common Findings

### Description Issues
- Too vague ("Helps with PDFs") → needs specific capabilities and trigger contexts
- Too narrow → misses valid trigger scenarios
- Declarative instead of imperative → "This skill does X" vs "Use when X"
- Over-broad → triggers on near-miss prompts

### Body Issues
- Explains concepts the agent already knows → cut
- No gotchas section → add non-obvious edge cases
- Presents menus of options → pick a default
- Overly comprehensive → move reference material out, keep core instructions
- Deeply nested references → flatten to one level

### Structure Issues
- SKILL.md over 500 lines → split into `references/`
- No progressive disclosure pointers → add "when to load" instructions
- Scripts without `--help` or error handling → improve agentic UX

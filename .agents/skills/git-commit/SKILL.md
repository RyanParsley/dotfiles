---
name: git-commit
description: Create git commits. Use when committing changes, creating PRs, or preparing code for review.
---

# Commits

## Format (Conventional Commits)

```
<type>(<scope>): <description>

[optional body]

[optional footer: Closes #<issue>]
```

## Types

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `test` | Adding or updating tests |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `chore` | Maintenance tasks (deps, config, CI, build) |
| `ci` | CI configuration changes |
| `perf` | Performance improvements |

## Rules

- **Imperative mood**: "Add X" not "Added X", "Fix Y" not "Fixes Y"
- **50 chars max** first line
- **72 char wrap** body
- **One purpose per commit**
- **Reference issues**: `Closes #123` or `Fixes #456` in footer

## Examples

```
feat(cli): add journal read command

Implement cerebro journal read for accessing daily entries.
Closes #42
```

```
fix(config): use XDG config directory on Linux

Previously used ~/.config/cerebro which violated XDG base
directory spec on systems with $XDG_CONFIG_HOME set.
```

```
chore: bump tokio to 1.40
```

## Gotchas

- **NEVER amend pushed commits** unless explicitly requested — it rewrites history.
- **Pre-commit hook may auto-modify files** — `git add` the modified files and re-commit if needed.
- ** lefthook** runs on commit — hooks must pass before push.
- **Scope** is optional but recommended for focused repos. Omit when a change spans multiple areas or the scope is unclear.
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

## Branches & Worktrees

Never commit on the default branch in the primary checkout. Anything that
becomes a PR gets its own branch **and its own worktree**, created with the `wt`
CLI (worktrunk) so paths, base branch, and setup hooks stay consistent:

```bash
wt switch --create <type>/<slug>   # branch + worktree (+ project pre-start hooks)
# ...work and commit inside the worktree...
wt merge                           # or gh pr create, then gh pr merge --squash --delete-branch
wt remove <type>/<slug>            # also deletes the branch, if merged
```

- **Branch names match commit types**: `feat/`, `fix/`, `refactor/`, `docs/`,
  `chore/`, `test/` plus a kebab-case slug
- **Project config lives in `.config/wt.toml`** (e.g. `pre-start = "npm ci"`).
  A first-time hook command needs approval (`wt config approvals`) — an
  unapproved hook looks like a broken worktree, not a config problem
- **`wt list` / `git worktree list`** shows what is in flight
- **Why:** parallel agents and concurrent PRs share one `.git`. Separate working
  trees keep checkouts, stashes, and `node_modules` from colliding
- **Never bypass hooks.** No `git commit --no-verify`, and no reading hook source
  looking for a bypass. Both skip lint/format and commitlint at once,
  and CI re-runs the checks against whatever lands
- **Merge commits and release bumps on the default branch are human actions.** If
  one seems required, ask instead of working around the guard
- **If a hook legitimately blocks correct work:** fix what it flagged, then commit
  again. Auto-modified files need `git add` first (see Gotchas)

## Gotchas

- **NEVER amend pushed commits** unless explicitly requested. It rewrites history.
- **Pre-commit hook may auto-modify files** — `git add` the modified files and re-commit if needed.
- **Hook managers vary** (husky, lefthook). Hooks must pass before push, and a
  green local run is not proof CI agrees. Pre-commit hooks usually check only
  staged files, while CI checks the whole repository.
- **Scope** is optional but recommended for focused repos. Omit when a change spans multiple areas or the scope is unclear.
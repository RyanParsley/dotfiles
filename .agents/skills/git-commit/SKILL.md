---
name: git-commit
description: Create git commits. Use when committing changes, creating PRs, or preparing code for review.
---

# Commits

```bash
git status
git add <files>
git commit -m "message"
```

## Conventions

- One purpose per commit
- Imperative mood: "Add X" not "Added X"
- 50 chars max first line
- Body if needed (72 char wrap)
- Reference issues: #123

## Example

```
Add user authentication flow

Implement JWT auth with refresh tokens.
Fixes #123
```

## Gotchas

- NEVER amend pushed commits unless explicitly requested
- Pre-commit hook may auto-modify files — amend only in this case
- lefthook runs on commit — hooks must pass
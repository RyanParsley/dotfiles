---
name: cerebro-cli
description: Query the cerebro cortex knowledge base for project context, journal entries, intent/goals, TODOs, and statistics. Use when the user asks about their projects, wants to read journal entries, check goals/intentions, search for TODOs across repos, or get an overview of their activity data. Also use when browsing what the user has been working on across their side projects.
license: MIT
compatibility: "Requires `cerebro` CLI installed at `~/.local/bin/cerebro` and a cortex directory (default `~/Projects/cortex`)."
metadata:
  author: ryan
  version: "1.0"
---

# Cerebro CLI

Query the cerebro cortex — a developer's knowledge base that tracks projects, sessions, commits, TODOs, journal entries, and intent/goals across many side projects.

## Cortex Layout

```
~/Projects/cortex/
├── config.toml              # Project registry (name, repo_path, active)
├── content/
│   ├── projects/            # Generated project status pages (.md)
│   ├── notes/projects/      # Manual project notes (.md)
│   ├── journal/YYYY/MM/DD.md # Daily journal entries
│   ├── intent/daily/        # Daily intent/goals
│   ├── intent/weekly/       # Weekly intent/goals
│   ├── intent/monthly/      # Monthly intent/goals
│   └── intent/yearly/       # Yearly intent/goals
```

## Commands

All commands output JSON to stdout. Use `-c` to override the config path.

### Projects

```bash
# List all active projects
cerebro projects list

# List all projects including inactive
cerebro projects list --active-only=false

# Read a specific project's context
cerebro projects read <name>
```

**Output — `projects list`:**
```json
{
  "count": 21,
  "projects": [
    { "name": "cerebro", "active": true, "last_updated": "2026-05-16" }
  ]
}
```

**Output — `projects read`:**
```json
{
  "name": "cerebro",
  "content": "# Project: cerebro\n\n## Generated Status\n...\n\n## Manual Notes\n...",
  "has_generated": true,
  "has_manual_notes": true
}
```

### Journal

```bash
# Read today's journal
cerebro journal today

# Read a specific date
cerebro journal read 2026-05-15
```

**Output:**
```json
{
  "date": "2026-05-15",
  "content": "# 2026-05-15\n\n## Sessions\n...\n\n## Commits\n...",
  "exists": true
}
```

If no entry exists, `exists` is `false` and `content` is a not-found message.

### Intent / Goals

```bash
cerebro intent <period> <identifier>
```

Periods: `daily`, `weekly`, `monthly`, `yearly`

```bash
cerebro intent daily 2026-05-16
cerebro intent weekly 2026-W20
cerebro intent monthly 2026-05
cerebro intent yearly 2026
```

**Output:**
```json
{
  "period": "daily",
  "identifier": "2026-05-16",
  "content": "...",
  "exists": true
}
```

### TODOs

```bash
# Search all projects
cerebro todos

# Filter by keyword
cerebro todos --keyword "refactor"

# Limit to one project
cerebro todos --project cerebro

# Both filters
cerebro todos --keyword "fix" --project cerebro
```

**Output:**
```json
{
  "count": 5,
  "todos": [
    {
      "project": "cerebro",
      "file": "crates/cerebro/src/main.rs",
      "line": 42,
      "text": "// TODO: add error handling here"
    }
  ]
}
```

TODOs are found by scanning source repos for `TODO`, `FIXME`, `HACK`, `XXX` patterns, plus generated project pages.

### Statistics

```bash
cerebro stats
```

**Output:**
```json
{
  "project_count": 21,
  "todo_count": 462,
  "journal_entries": 84,
  "cortex_path": "/Users/ryan/Projects/cortex"
}
```

## Common Workflows

### "What am I working on?"

```bash
cerebro stats                  # Quick overview
cerebro projects list          # See active projects
cerebro journal today          # Today's activity
```

### "What did I work on last week?"

```bash
cerebro journal read 2026-05-12
cerebro journal read 2026-05-13
# ... check each day
```

### "What are my current goals?"

```bash
cerebro intent weekly 2026-W20
cerebro intent daily 2026-05-16
```

### "What TODOs do I have for this project?"

```bash
cerebro todos --project <name>
cerebro todos --project <name> --keyword "fix"
```

### "Tell me about this project"

```bash
cerebro projects read <name>
```

## Output Format Templates

When summarizing cortex data for the user, use this structure:

**Project Overview:**
```markdown
## {project_name}

- **Last updated**: {date}
- **Status**: {active/inactive}
- **Cortex path**: {path to generated page}

{generated content excerpt}

{manual notes excerpt if present}
```

**Daily Journal:**
```markdown
## {date}

### Sessions
{OpenCode sessions for the day}

### Commits
{commit list for the day}

### Notes
{any manual notes}
```

**Intent/Goals:**
```markdown
## {period}: {identifier}

{content}

**Status**: {exists/not found}
```

**TODO Summary:**
```markdown
## TODOs: {project or "all projects"}

Found {count} items:
- **{file}:{line}** — {todo text}
```

## Gotchas

- The cortex path defaults to the parent of `config.toml`. If using `-c`, point to the config file, not the directory.
- `projects list` only shows active projects by default. Use `--active-only=false` to include inactive.
- Journal and intent entries return `"exists": false` (not an error) when no file is found.
- The `todos` command scans actual source repositories listed in `config.toml` — it can be slow for large codebases.
- Project names in `todos --project` must match the `name` field in `config.toml`, not the repo directory name.

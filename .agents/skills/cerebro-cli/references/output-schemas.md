# Cerebro CLI Output Schemas

All commands output JSON to stdout. Exit code 0 on success, non-zero on error.

## Error Format

```json
{
  "error": "Project 'unknown' not found"
}
```

## Projects

### `projects list`

```typescript
interface ProjectsList {
  count: number;
  projects: ProjectEntry[];
}

interface ProjectEntry {
  name: string;
  active: boolean;
  last_updated: string | null;  // "YYYY-MM-DD" or null if file doesn't exist
}
```

### `projects read <name>`

```typescript
interface ProjectRead {
  name: string;
  content: string;       // Combined generated + manual markdown
  has_generated: boolean;
  has_manual_notes: boolean;
}
```

Error if project not found (exit code non-zero).

## Journal

### `journal read <YYYY-MM-DD>` / `journal today`

```typescript
interface JournalEntry {
  date: string;          // "YYYY-MM-DD"
  content: string;       // Markdown content or not-found message
  exists: boolean;       // true if file was found
}
```

Never errors — always returns JSON with `exists: false` for missing dates.

## Intent

### `intent <period> <identifier>`

```typescript
interface IntentEntry {
  period: string;         // "daily" | "weekly" | "monthly" | "yearly"
  identifier: string;     // e.g., "2026-05-16", "2026-W20", "2026-05", "2026"
  content: string;        // Markdown content or not-found message
  exists: boolean;
}
```

Valid identifiers:
- `daily`: `YYYY-MM-DD` (e.g., `2026-05-16`)
- `weekly`: `YYYY-WNN` (e.g., `2026-W20`)
- `monthly`: `YYYY-MM` (e.g., `2026-05`)
- `yearly`: `YYYY` (e.g., `2026`)

Invalid period string returns exit code non-zero.

## TODOs

### `todos [--keyword <kw>] [--project <name>]`

```typescript
interface TodosResult {
  count: number;
  todos: TodoEntry[];
}

interface TodoEntry {
  project: string;   // Project name or repo directory name
  file: string;      // Relative path within repo, or "(generated)"
  line: number;      // 1-based line number
  text: string;      // The full line content (trimmed)
}
```

Patterns matched: `TODO`, `FIXME`, `HACK`, `XXX` (case-insensitive).

Searches:
1. Source repositories listed in `config.toml` (skips `target`, `node_modules`, `dist`, `build`, dotfiles)
2. Generated project pages in `content/projects/`

## Stats

### `stats`

```typescript
interface StatsResult {
  project_count: number;
  todo_count: number;
  journal_entries: number;
  cortex_path: string;
}
```

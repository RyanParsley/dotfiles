---
name: brave-search
description: Web search and content extraction via Brave Search API. Use for searching documentation, facts, or any web content. Lightweight, no browser required.
---

# Brave Search

Web search and content extraction using the official Brave Search API. No browser required.

## Setup

Requires a Brave Search API account with a free subscription. A credit card is required to create the free subscription (you won't be charged).

1. Create an account at https://api-dashboard.search.brave.com/register
2. Create a "Free AI" subscription
3. Create an API key for the subscription
4. Add to your shell profile (`~/.profile` or `~/.zprofile` for zsh):
   ```bash
   export BRAVE_API_KEY="your-api-key-here"
   ```
5. Install dependencies (run once):
   ```bash
   cd <base-dir>/scripts   # base-dir shown at the bottom of this skill
   npm install
   ```

## Search

```bash
node <base-dir>/scripts/search.js "query"                         # Basic search (5 results)
node <base-dir>/scripts/search.js "query" -n 10                   # More results (max 20)
node <base-dir>/scripts/search.js "query" --content               # Include page content as markdown
node <base-dir>/scripts/search.js "query" --freshness pw          # Results from last week
node <base-dir>/scripts/search.js "query" --freshness 2024-01-01to2024-06-30  # Date range
node <base-dir>/scripts/search.js "query" --country DE            # Results from Germany
node <base-dir>/scripts/search.js "query" -n 3 --content          # Combined options
```

### Options

- `-n <num>` - Number of results (default: 5, max: 20)
- `--content` - Fetch and include page content as markdown
- `--country <code>` - Two-letter country code (default: US)
- `--freshness <period>` - Filter by time:
  - `pd` - Past day (24 hours)
  - `pw` - Past week
  - `pm` - Past month
  - `py` - Past year
  - `YYYY-MM-DDtoYYYY-MM-DD` - Custom date range

## Extract Page Content

```bash
node <base-dir>/scripts/content.js https://example.com/article
```

Fetches a URL and extracts readable content as markdown.

## Output Format

```
--- Result 1 ---
Title: Page Title
Link: https://example.com/page
Age: 2 days ago
Snippet: Description from search results
Content: (if --content flag used)
  Markdown content extracted from the page...

--- Result 2 ---
...
```

## When to Use

- Searching for documentation or API references
- Looking up facts or current information
- Fetching content from specific URLs
- Any task requiring web search without interactive browsing

## Gotchas

- **`{baseDir}` is not substituted by OpenCode.** Construct the full path using the "Base directory" value injected at the bottom of this skill.
- **The "Free AI" subscription requires a credit card** despite being free. This surprises users during setup — guide them through it if they hesitate.
- **`--content` fetches and parses each result URL** — it's significantly slower than a plain search. Don't use it when snippets are sufficient.
- **API keys are per-subscription, not per-account.** If auth returns 401, verify the key belongs to the correct subscription type ("Free AI", not "Data for Search").

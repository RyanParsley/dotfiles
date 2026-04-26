# Woodpecker CI Rules

When the project contains `.woodpecker.yml` or `.woodpecker/`, these rules apply. If neither exists, ignore this file.

## Core Syntax

- Steps use `image:` (container) and `commands:` (array of strings)
- Environment variables use **map syntax**: `KEY: value` — NOT array syntax (`- KEY=value`)
- `when` conditions are **arrays of condition objects**
- No `uses:` directive — use container images or custom plugins
- Secrets via `from_secret:` in step settings

## Events

- `push`, `pull_request`, `pull_request_closed`, `tag`, `release`, `cron`, `manual`
- NOT `on: pull_request` (GitHub Actions syntax)

## Common Patterns

### Basic step
```yaml
steps:
  test:
    image: node:20
    commands:
      - npm ci
      - npm test
    when:
      - event: push
      - event: pull_request
```

### With secrets
```yaml
steps:
  deploy:
    image: alpine
    commands:
      - apk add openssh-client
      - ssh deploy@server "cd /app && git pull"
    settings:
      from_secret: deploy_key
    when:
      - event: tag
```

### Matrix builds
```yaml
steps:
  test:
    image: node:${NODE_VERSION}
    commands:
      - npm ci
      - npm test
    environment:
      NODE_VERSION:
        - "18"
        - "20"
        - "22"
```

### Pipeline dependencies
```yaml
steps:
  build:
    image: node:20
    commands:
      - npm ci
      - npm run build

  test:
    image: node:20
    commands:
      - npm test
    depends_on:
      - build
```

## Anti-Patterns

- Do NOT use `runs-on:`, `strategy:`, `env:` as array, `uses:`, `${{ }}`
- Do NOT use `.github/` paths
- Do NOT use `GITHUB_TOKEN` — use `${CI_COMMIT_TOKEN}` or secrets
- Do NOT use `${{ github.event }}` — use `${CI_COMMIT_*}`, `${CI_PULL_REQUEST_*}` env vars

## Codeberg Pages Deploy

Codeberg Pages deploys via SSH key to the `pages` branch. Typical deploy step:

```yaml
steps:
  deploy:
    image: alpine/git
    commands:
      - git clone git@codeberg.org:owner/repo.git -b pages _pages
      - cp -r dist/* _pages/
      - cd _pages && git add . && git commit -m "deploy" && git push
    when:
      - event: tag
```

See AGENTS.md for Codeberg-specific details.

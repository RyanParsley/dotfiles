# Evidence-First Principle

**Ground all technical claims in evidence.** Never infer, assume, or extrapolate beyond what documentation, source code, or tool output explicitly states. If the docs don't cover something, say "the docs don't cover this" — don't guess. When uncertain, look it up before answering. Cite the specific file, line, or doc section that supports each claim.

---

# Warnings Are Never "Fine"

**Every warning, error, or diagnostic is a legitimate problem to fix.** Never dismiss warnings as "known quirks," "harmless," "cosmetic," or "noise." Never say "this is expected" without verifying the root cause.

The pattern to break:
1. A tool outputs a warning
2. You rationalize it as acceptable
3. You move on without fixing it

The correct pattern:
1. A tool outputs a warning
2. You investigate why it happens
3. You fix the root cause
4. You verify the warning is gone

**Do not commit code that produces warnings.** If a warning exists, fix it before proceeding. If you can't fix it immediately, explain why and track it — but never normalize it.

---

# Default Forge Context: Codeberg/Forgejo

**This system defaults to Codeberg (codeberg.org) and Forgejo instances.** Assume Codeberg/Forgejo unless the git remote points elsewhere.

## Codeberg (codeberg.org) — DEFAULT

- **Software**: Forgejo (Gitea-compatible API)
- **API**: `https://codeberg.org/api/v1` (Swagger: https://codeberg.org/api/swagger)
- **CI**: Woodpecker CI (`.woodpecker.yml` or `.woodpecker/`)
- **CLI**: `fj` (forgejo-cli) — `brew install forgejo-cli`
- **Auth**: `CODEBERG_ACCESS_TOKEN` env var

### Codeberg PR/Issue Commands
```bash
fj pr create "Title" --body "Body"     # Create PR
fj pr create -aA                       # AGit + autofill (no push needed)
fj issue create "Title" --body "Body"  # Create issue
```

### Codeberg API (curl fallback)
```bash
curl -H "Authorization: token $CODEBERG_ACCESS_TOKEN" "https://codeberg.org/api/v1/..."
```

### Codeberg Pages
- Deploys via SSH key to `pages` branch
- Enable in repo settings → Pages
- CI deploy step typically pushes to `pages` branch with SSH key secret

---

## Self-Hosted Forgejo — DEFAULT

- **Software**: Forgejo (Gitea-compatible API)
- **API**: `https://<instance>/api/v1`
- **CI**: Woodpecker CI (`.woodpecker.yml` or `.woodpecker/`)
- **CLI**: `fj` (forgejo-cli)
- **Auth**: `FORGEJO_ACCESS_TOKEN` env var

### Forgejo PR/Issue Commands
```bash
fj -H <instance> pr create "Title" --body "Body"
fj -H <instance> issue create "Title" --body "Body"
```

### Forgejo API (curl fallback)
```bash
curl -H "Authorization: token $FORGEJO_ACCESS_TOKEN" "https://<instance>/api/v1/..."
```

---

## Non-Forgejo Remotes

If `git remote get-url origin` does NOT match `codeberg.org` or a known Forgejo instance, detect the forge and apply the appropriate rules below.

### GitHub (github.com)

- **Software**: GitHub
- **API**: `https://api.github.com`
- **CI**: GitHub Actions (`.github/workflows/`)
- **CLI**: `gh` — `brew install gh`
- **Auth**: `GITHUB_TOKEN` env var

```bash
gh pr create --title "Title" --body "Body"
gh issue create --title "Title" --body "Body"
curl -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/..."
```

### Azure DevOps (dev.azure.com)

- **Software**: Azure DevOps Services
- **API**: `https://dev.azure.com/{org}/{project}/_apis/`
- **CI**: Azure Pipelines (`azure-pipelines.yml`)
- **CLI**: `az` (Azure CLI) — `brew install azure-cli`
- **Auth**: `AZURE_DEVOPS_EXT_PAT` env var

```bash
az repos pr create --title "Title" --description "Body" --source-branch feature --target-branch main
az boards work-item create --type "User Story" --title "Title"
curl -u :$AZURE_DEVOPS_EXT_PAT "https://dev.azure.com/{org}/{project}/_apis/..."
```

### Unknown / GitLab / Other

- Detect from remote URL and use appropriate CLI/API
- If unsure, use `curl` with the forge's REST API
- Never assume GitHub syntax unless confirmed

---

## Universal Anti-Patterns

- Do NOT assume `.github/workflows/` — check for `.woodpecker/`, `azure-pipelines.yml`, or CI config
- Do NOT assume `GITHUB_TOKEN` — check which token env var is set
- Do NOT assume `main` branch — check the repo's default branch
- Do NOT assume `actions/checkout@v4` — use the CI system's native checkout method

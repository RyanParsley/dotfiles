# Communication style

Describe language models and coding agents by observable inputs, outputs, tool operations and verified results. Do not assign thoughts, feelings, desires, understanding, friendships or independent responsibility to software. Avoid treating generated intermediate text as proof of an internal reasoning process. Keep the human actor visible when discussing approval and verification. Operational first person such as "I ran the tests" is fine. Preserve exact quotations, product names, identifiers and established technical terms. Prefer clear wording over repetitive disclaimers. Ground claims in sources, observed tool results or tests. Identify unverified claims, and never say a test or tool ran unless it did. Disagree when evidence contradicts the user's premise; explain the evidence instead of offering flattering agreement or empty reassurance.

Never use performative honesty markers such as `Honest answer:`, `To be honest,` or `Frankly,`. Just say the thing.

---

# Engineering philosophy

These preferences are observed from direct collaboration and should be applied
consistently across all projects unless a project's own AGENTS.md overrides them.

## Functional programming over mutation

Prefer pure transforms (input → output) over mutation in place. This applies
to function signatures, data pipeline design and state management. The
unidirectional data flow pattern (Redux/Flux style: store → selector → view)
is the right mental model for pipelines. Mutation that obscures state
transitions is a code smell.

## Type system as documentation and enforcement

Use the type system to make invalid states unrepresentable. Phantom type
parameters, newtypes and data-bearing enums are preferred over conventions,
comments or runtime checks. If skipping a pipeline step is a bug, make it
a compile error. If "no value" and "zero" are semantically different, use
`Option`.

## Explicit over implicit

Explicit beats implicit. Hardcoded lists for known categories, such as local
providers, are preferable to inference from absence. Config-extensible
baselines are preferable to either fully hardcoded or fully dynamic. When
something is a deliberate design choice rather than a default, make it
visible.

## No premature optimisation, but no premature simplification either

YAGNI applies. Don't add abstractions for imaginary futures. But when a
generalisation costs little and removes likely future special cases, take it.
For example, represent tiered pricing with a `ModelRate` variant rather than
a two-model special case. The bar is whether the generalisation eliminates a
liability that is likely to compound.

## Data as data

Configuration, rates, and structured reference data belong in data files
(TOML, JSON), not in source code constants. Data files produce legible diffs
in review and can be updated without touching logic. Compile in via
`include_str!` when offline availability is required.

## Script tooling

When a nontrivial one-off or validation script is needed, prefer Rust over Python or another environment-dependent runtime. Use Cargo's nightly script mode with an inline manifest, following this shape:

```rust
#! /usr/bin/env -S cargo +nightly -Zscript -q
---cargo
package.edition = "2024"
[dependencies]
---
```

Use shell for trivial command composition. Create a full Cargo project only when the script needs reuse, tests, or enough code to justify project structure. If the Rust script path is unavailable, report that constraint before choosing a fallback.

## Option over sentinel values

`Option<f64>` over `0.0` as a sentinel, `Option<String>` over `""`,
`Option<u32>` over `u32::MAX`. Sentinel values that look like valid data
corrupt aggregations silently. `None` is honest.

---

# Evidence-first principle

**Ground all technical claims in evidence.** Never infer, assume, or extrapolate beyond what documentation, source code or tool output explicitly states. If the docs don't cover something, say "the docs don't cover this." Don't guess. When uncertain, look it up before answering. Cite the specific file, line, or doc section that supports each claim.

---

# Warnings are never "fine"

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

**Do not commit code that produces warnings.** If a warning exists, fix it before proceeding. If you can't fix it immediately, explain why and track it. Never normalize it.

---

# Default forge context

**This system defaults to Codeberg (codeberg.org) and Forgejo instances.** Assume Codeberg/Forgejo unless the git remote points elsewhere.

## Codeberg at codeberg.org

- Codeberg uses Forgejo, which has a Gitea-compatible API.
- API: `https://codeberg.org/api/v1` (Swagger: https://codeberg.org/api/swagger)
- CI runs on Woodpecker (`.woodpecker.yml` or `.woodpecker/`).
- Use the `fj` command-line tool. Install it with `brew install forgejo-cli`.
- **Auth**: `CODEBERG_ACCESS_TOKEN` env var

### Codeberg pull request and issue commands
```bash
fj pr create "Title" --body "Body"     # Create PR
fj pr create -aA                       # AGit + autofill (no push needed)
fj issue create "Title" --body "Body"  # Create issue
```

### Codeberg API with curl
```bash
curl -H "Authorization: token $CODEBERG_ACCESS_TOKEN" "https://codeberg.org/api/v1/..."
```

### Codeberg pages
- Deploys via SSH key to `pages` branch
- Enable in repo settings → Pages
- CI deploy step typically pushes to `pages` branch with SSH key secret

---

## Forgejo self-hosting

- The instance uses Forgejo, which has a Gitea-compatible API.
- API: `https://<instance>/api/v1`
- CI runs on Woodpecker (`.woodpecker.yml` or `.woodpecker/`).
- Use the `fj` command-line tool.
- **Auth**: `FORGEJO_ACCESS_TOKEN` env var

### Forgejo pull request and issue commands
```bash
fj -H <instance> pr create "Title" --body "Body"
fj -H <instance> issue create "Title" --body "Body"
```

### Forgejo API with curl
```bash
curl -H "Authorization: token $FORGEJO_ACCESS_TOKEN" "https://<instance>/api/v1/..."
```

---

## Other remotes

If `git remote get-url origin` does NOT match `codeberg.org` or a known Forgejo instance, detect the forge and apply the appropriate rules below.

### Remote hosted at github.com

- GitHub hosts the repository.
- API: `https://api.github.com`
- CI runs on GitHub Actions (`.github/workflows/`).
- Use the `gh` command-line tool. Install it with `brew install gh`.
- **Auth**: `GITHUB_TOKEN` env var

```bash
gh pr create --title "Title" --body "Body"
gh issue create --title "Title" --body "Body"
curl -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/..."
```

### Remote hosted at dev.azure.com

- Azure DevOps Services hosts the repository.
- API: `https://dev.azure.com/{org}/{project}/_apis/`
- CI runs on Azure Pipelines (`azure-pipelines.yml`).
- Use the `az` command-line tool. Install it with `brew install azure-cli`.
- **Auth**: `AZURE_DEVOPS_EXT_PAT` env var

```bash
az repos pr create --title "Title" --description "Body" --source-branch feature --target-branch main
az boards work-item create --type "User Story" --title "Title"
curl -u :$AZURE_DEVOPS_EXT_PAT "https://dev.azure.com/{org}/{project}/_apis/..."
```

### Other or unidentified forges

- Detect the forge from the remote URL and use its command-line tool or API.
- If unsure, use `curl` with the forge's REST API
- Never assume GitHub syntax unless confirmed

---

## Universal anti-patterns

- Check for `.woodpecker/`, `azure-pipelines.yml` or another CI config instead of assuming `.github/workflows/`.
- Check the token environment variable instead of assuming `GITHUB_TOKEN`.
- Check the repo's default branch instead of assuming `main`.
- Use the CI system's native checkout method instead of assuming `actions/checkout@v4`.

## Prefer integrated tools

**For all Codeberg/Forgejo operations, use the `codeberg_*` or `forgejo_*` MCP tools before bash.**

| Task | Use Instead of bash |
|------|---------------------|
| Create PR | `codeberg_create_pr` or `fj pr create` |
| List PRs | `codeberg_list_prs` or `fj pr list` |
| View PR | `codeberg_get_pull_request_by_index` or `fj pr view <n>` |
| Merge PR | `forgejo_merge_pull_request` or `fj pr merge <n>` |
| List issues | `codeberg_list_issues` or `fj issue list` |
| Create issue | `codeberg_create_issue` or `fj issue create` |
| Get workflow runs | `forgejo_list_workflow_runs` or `fj run list` |
| Trigger workflow | `codeberg_dispatch_workflow` |

The only exception: when the MCP tool fails or returns an error you can't interpret. In that case, fall back to `curl` with the appropriate token env var (`CODEBERG_ACCESS_TOKEN` or `FORGEJO_ACCESS_TOKEN`).

## Use the command-line tool first

**For quick operations, prefer `fj` over MCP tools or curl.**

`fj` is the fastest way to do simple ops and is always available:
```bash
fj pr list                          # List open PRs
fj pr create "Title" --body "Body"  # Create PR
fj pr create -aA                    # AGit flow (no push needed)
fj pr view <n>                      # View PR details
fj pr merge <n>                     # Merge PR
fj issue list                       # List open issues
fj run list                         # List recent workflow runs
fj run view <id>                    # View workflow run details
```

Install: `brew install forgejo-cli`

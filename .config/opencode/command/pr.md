# /pr

Create a pull request from the current branch.

## Steps

1. Get the current branch name: `git branch --show-current`
2. Create the PR using the appropriate CLI:

### Codeberg / Forgejo (default)
```bash
fj pr create "Title" --body "Body"
# Or with explicit branches:
fj pr create "Title" --body "Body" --base main --head <current-branch>
# Or AGit workflow (no push needed):
fj pr create -aA
```

### GitHub
```bash
gh pr create --title "Title" --body "Body"
```

### Azure DevOps
```bash
az repos pr create --title "Title" --description "Body" --source-branch <current-branch> --target-branch main
```

3. Print the PR URL on success

## If CLI Not Available

Fall back to the forge's API via `curl` (see AGENTS.md for API patterns).

# Dotfiles maintenance commands
#
# Two-repo setup:
#   ~/dotfiles        - public, shared across all machines (home default)
#   ~/.dotfiles-local - private, work-only overrides (only stowed on work machine)
#
# OpenCode config strategy:
#   Global (~/.config/opencode/opencode.jsonc) is symlinked from ~/dotfiles
#   and contains home defaults (codeberg, forgejo, dokploy, local LLMs all enabled).
#   On work machines, ~/.dotfiles-local is also stowed, which drops
#   opencode-work.fish into fish conf.d, setting OPENCODE_CONFIG to point at
#   the work overlay (~/.dotfiles-local/.config/opencode/opencode.work.jsonc).
#   That overlay disables home MCPs and adds work-only ones.
#
# Skills stow strategy:
#   ~/.agents/skills/ is populated from two sources via --no-folding:
#     - ~/dotfiles/.agents/skills/     (public skills)
#     - ~/.dotfiles-local/.agents/skills/ (work-only skills, e.g. ado-build-logs)
#   Stow invocation targets ~/.agents directly (not ~/.agents/skills):
#     cd ~/dotfiles/.agents && stow --no-folding --ignore=node_modules --target=~/.agents --stow skills
#     cd ~/.dotfiles-local/.agents && stow --no-folding --ignore=node_modules --target=~/.agents --stow skills
#
# Pi models strategy:
#   ~/.pi/agent/models.json    -> symlink to ~/dotfiles/.pi/agent/models.json (public/local providers)
#   ~/.pi/agent/models.work.json -> symlink to ~/.dotfiles-local/.pi/agent/models.work.json (work providers)

# Set shell explicitly
set shell := ["zsh", "-c"]

# Default recipe - show available commands
default:
    @just --list

# === Stow management ===

# Restow public dotfiles (fix broken symlinks)
restow:
    cd ~/dotfiles && stow --restow .
    cd ~/dotfiles/.agents && stow --no-folding --ignore='node_modules' --target=$$HOME/.agents --restow skills

# Restow work-local dotfiles (run on work machine only)
restow-local:
    cd ~/.dotfiles-local && stow --restow .
    cd ~/.dotfiles-local/.agents && stow --no-folding --ignore='node_modules' --target=$$HOME/.agents --restow skills

# Restow both repos (work machine only)
restow-all: restow restow-local

# Check stow status for public dotfiles (simulate)
stow-check:
    cd ~/dotfiles && stow --simulate . 2>&1 | grep -v "not owned by stow"

# === Git maintenance ===

# Show dotfiles status
status:
    cd ~/dotfiles && git status --short

# Show recent commits
log:
    cd ~/dotfiles && git log --oneline -10

# Push to remote
push:
    cd ~/dotfiles && git push

# === OpenCode config ===

# Show which opencode config is active on this machine
which-config:
    #!/usr/bin/env zsh
    if [[ -n "$OPENCODE_CONFIG" ]]; then
        echo "Work overlay active: $OPENCODE_CONFIG"
    else
        echo "Home/global config only: ~/.config/opencode/opencode.jsonc"
    fi
    echo ""
    echo "Resolved symlink:"
    ls -la ~/.config/opencode/opencode.jsonc 2>/dev/null || echo "  Not symlinked (stow may need to run)"

# === Link verification ===

# Verify all symlinks are correct
check-links:
    @echo "=== Checking ~/.config/opencode symlinks ==="
    @ls -la ~/.config/opencode/ | grep -E "^l" || echo "No symlinks found"
    @echo ""
    @echo "=== Checking ~/.pi/agent symlinks ==="
    @ls -la ~/.pi/agent/ 2>/dev/null | grep -E "^l" || echo "No symlinks found"
    @echo ""
    @echo "=== Checking ~/.agents skill symlinks (sample) ==="
    @ls ~/.agents/ 2>/dev/null | head -5 || echo "No skills found"
    @ls -la ~/.agents/ado-build-logs/SKILL.md 2>/dev/null || echo "  ado-build-logs not stowed (work machine only)"

# === Full system check ===

# Run all checks
check: stow-check check-links which-config status
    @echo "All checks complete."

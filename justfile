# Dotfiles maintenance commands

# Set shell explicitly
set shell := ["zsh", "-c"]

# Default recipe - show available commands
default:
    @just --list

# === Stow management ===

# Restow all dotfiles (fix broken symlinks)
restow:
    cd ~/.dotfiles && stow --restow .

# Stow specific packages
stow package:
    cd ~/.dotfiles && stow --restow {{package}}

# Check stow status (simulate)
stow-check:
    cd ~/.dotfiles && stow --simulate .

# === Agent Skills ===

# Update pi-skills to latest
update-skills:
    cd ~/.agents/skills/pi-skills && git pull

# Check for skill updates (dry run)
check-skills:
    cd ~/.agents/skills/pi-skills && git fetch --dry-run

# Re-clone skills from scratch
reclone-skills:
    rm -rf ~/.agents/skills/pi-skills
    git clone https://github.com/badlogic/pi-skills ~/.agents/skills/pi-skills

# === Git maintenance ===

# Show dotfiles status
status:
    cd ~/.dotfiles && git status --short

# Show recent commits
log:
    cd ~/.dotfiles && git log --oneline -10

# Push to remote
push:
    cd ~/.dotfiles && git push

# === Link verification ===

# Verify all symlinks are correct
check-links:
    @echo "=== Checking ~/.config symlinks ==="
    @ls -la ~/.config/opencode/ | grep -E "^l" || echo "No symlinks found"
    @echo ""
    @echo "=== Checking ~/.pi symlinks ==="
    @ls -la ~/.pi/agent/ | grep -E "^l" || echo "No symlinks found"
    @echo ""
    @echo "=== Checking ~/.agents symlinks ==="
    @ls -la ~/.agents/ | grep -E "^l" || echo "No symlinks found"

# === Full system check ===

# Run all checks
check: stow-check check-links status
    @echo "All checks passed!"

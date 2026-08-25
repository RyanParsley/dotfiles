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
#   Stow invocation targets ~/.agents/skills:
#     cd ~/dotfiles/.agents && stow --no-folding --ignore=node_modules --target=$HOME/.agents/skills --stow skills
#     cd ~/.dotfiles-local/.agents && stow --no-folding --ignore=node_modules --target=$HOME/.agents/skills --stow skills
#
# Pi models strategy:
#   ~/.pi/agent/models.json    -> symlink to ~/dotfiles/.pi/agent/models.json (public/local providers)
#   ~/.pi/agent/models.work.json -> symlink to ~/.dotfiles-local/.pi/agent/models.work.json (work providers)

# Set shell explicitly
set shell := ["zsh", "-c"]

# Default recipe - show available commands
default:
    @just --list

# === Nix-darwin ===

# Apply nix-darwin configuration
switch:
    sudo darwin-rebuild switch --flake ~/dotfiles
    just verify-system

# Update flake inputs and rebuild
update:
    nix --extra-experimental-features "nix-command flakes" flake update && just switch

# Verify the activated nix-darwin system and terminal toolchain
verify-system:
    #!/usr/bin/env zsh
    set -eu

    fail() {
        print -u2 -- "FAIL: $1"
        exit 1
    }

    [[ -e /run/current-system ]] || fail "/run/current-system is missing"
    nix store info --json | jq -e '.trusted == true and .url == "daemon"' >/dev/null \
        || fail "Nix daemon is unavailable or untrusted"
    [[ "$(nix config show require-sigs)" == "true" ]] || fail "Nix signature verification is disabled"
    nix config show trusted-public-keys | grep -Fq \
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" \
        || fail "nix-community signing key is incorrect"

    fresh_zsh=(env -i HOME="$HOME" USER="$USER" SHELL=/bin/zsh TERM=xterm-256color /bin/zsh -lc)

    [[ "$(${fresh_zsh[@]} 'whence -p mise')" == "/run/current-system/sw/bin/mise" ]] \
        || fail "mise does not resolve from the active Nix system"
    ${fresh_zsh[@]} 'MISE_OFFLINE=1 mise --version' | grep -Fq "macos-arm64" \
        || fail "mise is not the official macOS ARM binary"

    [[ "$(${fresh_zsh[@]} 'whence -p tmux')" == "/run/current-system/sw/bin/tmux" ]] \
        || fail "tmux is shadowed by a non-Nix installation"
    ${fresh_zsh[@]} 'tmux -V' | grep -Fq "tmux 3.7c" || fail "unexpected tmux version"

    ${fresh_zsh[@]} 'pkg-config --exists MagickWand' || fail "pkg-config cannot resolve MagickWand"

    mise_log="$(mktemp)"
    script -q "$mise_log" env -i HOME="$HOME" USER="$USER" SHELL=/bin/zsh TERM=xterm-256color \
        /bin/zsh -ilc 'mise doctor' </dev/null >/dev/null 2>&1 || fail "mise doctor failed"
    strings "$mise_log" | grep -Fq "No problems found" || fail "mise doctor reported a problem"

    ghostty_bin="/Applications/Ghostty.app/Contents/MacOS/ghostty"
    [[ -x "$ghostty_bin" ]] || fail "Ghostty executable is missing"
    "$ghostty_bin" +version >/dev/null || fail "Ghostty failed to report its version"

    nvim_log="$(mktemp)"
    trap 'rm -f "$mise_log" "$nvim_log"' EXIT
    script -q "$nvim_log" env -i HOME="$HOME" USER="$USER" SHELL=/bin/zsh TERM=xterm-256color \
        /bin/zsh -ilc \
        'exec nvim --cmd "autocmd VimEnter * ++once qall"' </dev/null >/dev/null 2>&1 \
        || fail "Neovim failed to start"
    if strings "$nvim_log" | grep -Eq 'pkg-config|MagickWand|Error detected|Failed to run'; then
        strings "$nvim_log" >&2
        fail "Neovim emitted a startup error"
    fi

    print -- "System verification passed: $(readlink /run/current-system)"

# === Stow management ===

# Restow public dotfiles (fix broken symlinks)
restow:
    rm -f ~/dotfiles/result
    cd ~/dotfiles && stow --restow --ignore=result .

# Restow work-local dotfiles (run on work machine only)
restow-local:
    cd ~/.dotfiles-local && stow --restow .
    cd ~/.dotfiles-local/.agents && stow --no-folding --ignore='node_modules' --target=$HOME/.agents/skills --restow skills

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

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
# Pi Stow packages:
#   pi-common - extensions and project defaults shared by every machine
#   pi-home   - home settings and models (OpenCode + Ollama, Qwen default)
#   pi-work   - private work settings and models (Copilot + Gemma, no OpenCode)
# pi-common and one machine profile merge into ~/.pi with --no-folding so
# Pi's runtime files can coexist with managed links.

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
    brew upgrade
    cargo install-update -a

# Verify the activated nix-darwin system and terminal toolchain
verify-system:
    #!/usr/bin/env zsh
    set -eu

    fail() {
        print -u2 -- "FAIL: $1"
        exit 1
    }

    kill_tree() {
        local pid="$1"
        local sig="${2:-TERM}"
        local child
        for child in $(pgrep -P "$pid" 2>/dev/null); do
            kill_tree "$child" "$sig"
        done
        kill "-$sig" "$pid" 2>/dev/null
    }

    # Run a command with a hard wall-clock timeout, killing its entire
    # process tree (not just the immediate child) if it overruns. Avoids
    # depending on GNU coreutils' timeout/gtimeout, which aren't guaranteed
    # to be installed.
    run_with_timeout() {
        local seconds="$1"; shift
        "$@" &
        local pid=$!
        (
            sleep "$seconds"
            kill -0 "$pid" 2>/dev/null || exit 0
            kill_tree "$pid" TERM
            sleep 1
            kill_tree "$pid" KILL
        ) &
        local watchdog=$!
        local rc=0
        wait "$pid" 2>/dev/null || rc=$?
        kill "$watchdog" 2>/dev/null
        wait "$watchdog" 2>/dev/null
        return "$rc"
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
    run_with_timeout 30 script -q "$mise_log" env -i HOME="$HOME" USER="$USER" SHELL=/bin/zsh TERM=xterm-256color \
        /bin/zsh -ilc 'mise doctor' </dev/null >/dev/null 2>&1 || fail "mise doctor failed or timed out"
    strings "$mise_log" | grep -Fq "No problems found" || fail "mise doctor reported a problem"

    ghostty_bin="/Applications/Ghostty.app/Contents/MacOS/ghostty"
    [[ -x "$ghostty_bin" ]] || fail "Ghostty executable is missing"
    "$ghostty_bin" +version >/dev/null || fail "Ghostty failed to report its version"

    nvim_log="$(mktemp)"
    trap 'rm -f "$mise_log" "$nvim_log"' EXIT
    run_with_timeout 20 script -q "$nvim_log" env -i HOME="$HOME" USER="$USER" SHELL=/bin/zsh TERM=xterm-256color \
        /bin/zsh -ilc \
        'exec nvim --cmd "autocmd VimEnter * ++once qall"' </dev/null >/dev/null 2>&1 \
        || fail "Neovim failed to start or timed out"
    if strings "$nvim_log" | grep -Eq 'pkg-config|MagickWand|Error detected|Failed to run'; then
        strings "$nvim_log" >&2
        fail "Neovim emitted a startup error"
    fi

    print -- "System verification passed: $(readlink /run/current-system)"

# === Stow management ===

# Restow public dotfiles. Install the home Pi profile only when no work profile exists.
restow:
    rm -f ~/dotfiles/result
    cd ~/dotfiles && stow --no-folding --restow --ignore=result .
    cd ~/dotfiles && stow --no-folding --target=$HOME --restow pi-common
    if [[ ! -d ~/.dotfiles-local/pi-work ]]; then cd ~/dotfiles && stow --no-folding --target=$HOME --restow pi-home; fi
    cd ~/dotfiles/.agents && stow --no-folding --ignore='node_modules' --target=$HOME/.agents/skills --restow skills

# Restow work-local dotfiles and select the mutually exclusive work Pi profile.
restow-local:
    cd ~/dotfiles && stow --no-folding --target=$HOME --delete pi-home
    cd ~/.dotfiles-local && stow --no-folding --restow --ignore='^pi-work$' .
    cd ~/.dotfiles-local && stow --no-folding --target=$HOME --restow pi-work
    cd ~/.dotfiles-local/.agents && stow --no-folding --ignore='node_modules' --target=$HOME/.agents/skills --restow skills

# Restow both repos (work machine only)
restow-all: restow restow-local

# Check Stow operations for this machine without changing files.
stow-check:
    cd ~/dotfiles && stow --simulate --no-folding .
    cd ~/dotfiles && stow --simulate --no-folding --target=$HOME pi-common
    if [[ ! -d ~/.dotfiles-local/pi-work ]]; then cd ~/dotfiles && stow --simulate --no-folding --target=$HOME pi-home; fi
    if [[ -d ~/.dotfiles-local/pi-work ]]; then cd ~/.dotfiles-local && stow --simulate --no-folding --ignore='^pi-work$' .; fi
    if [[ -d ~/.dotfiles-local/pi-work ]]; then cd ~/.dotfiles-local && stow --simulate --no-folding --target=$HOME pi-work; fi
    cd ~/dotfiles/.agents && stow --simulate --no-folding --ignore='node_modules' --target=$HOME/.agents/skills skills
    if [[ -d ~/.dotfiles-local/.agents/skills ]]; then cd ~/.dotfiles-local/.agents && stow --simulate --no-folding --ignore='node_modules' --target=$HOME/.agents/skills skills; fi

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
    @test -L ~/.pi/agent/settings.json || { echo "  Pi settings are not stowed"; exit 1; }
    @test -L ~/.pi/agent/models.json || { echo "  Pi models are not stowed"; exit 1; }
    @actual="$HOME/.pi/agent/settings.json"; \
        if [[ -d ~/.dotfiles-local/pi-work ]]; then expected="$HOME/.dotfiles-local/pi-work/.pi/agent/settings.json"; else expected="$HOME/dotfiles/pi-home/.pi/agent/settings.json"; fi; \
        [[ "${actual:A}" == "${expected:A}" ]] || { echo "  Wrong Pi profile is active"; exit 1; }
    @echo "  Pi profile: linked"
    @echo ""
    @echo "=== Checking ~/.agents skill symlinks ==="
    @test -L ~/.agents/skills/unslop/SKILL.md || { echo "  Public skills are not stowed"; exit 1; }
    @echo "  Public skills: linked"
    @if [[ -d ~/.dotfiles-local/.agents/skills ]]; then \
        test -L ~/.agents/skills/ado-build-logs/SKILL.md || { echo "  Work skills are not stowed"; exit 1; }; \
        echo "  Work skills: linked"; \
    else \
        echo "  Work skills: not installed on this machine"; \
    fi

# === Full system check ===

# Run all checks
check: stow-check check-links which-config status
    @echo "All checks complete."

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="$HOME/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Minimal bash configuration for compatibility
# Primary shell: zsh (see .zshrc)

# === PATH Configuration ===
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"

# === Tool Integrations ===
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# === Build Tool Configuration ===
export OPENSSL_ROOT_DIR=/usr/local/opt/openssl@3
export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:$(brew --prefix qt@5)
export PATH=$PATH:$(brew --prefix qt@5)/bin

# === Environment Variable Management ===
# direnv: automatically load/unload .envrc files per directory
# Install: brew install direnv (macOS), apt install direnv (Linux)
if command -v direnv > /dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# Machine-specific configuration (not in dotfiles repo)
# Use this file for: API keys, work vs personal configs, machine-specific paths
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local

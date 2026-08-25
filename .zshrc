
# Prioritize rustup cargo over Homebrew
[[ "$(uname)" == "Darwin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

# Path to oh-my-zsh — macOS uses ~/.oh-my-zsh, Nix uses the profile share path
if [[ "$(uname)" == "Darwin" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
else
  # Nix installs oh-my-zsh to the profile share directory
  export ZSH="${ZSH:-/root/.nix-profile/share/oh-my-zsh}"
fi

zstyle ':omz:update' mode auto

# Plugins — only load what exists in the current environment
# Base plugins (available everywhere oh-my-zsh is installed)
plugins=(git)

if [[ "$(uname)" == "Darwin" ]]; then
  # macOS-only plugins
  plugins+=(zoxide rust pm2 ng kubectl golang gcloud fzf nx-completion zsh-autosuggestions)
fi

source $ZSH/oh-my-zsh.sh

alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"

# gnuplot kitty integration — macOS only
if [[ "$(uname)" == "Darwin" ]]; then
  function iplot {
    cat <<EOF | gnuplot
    set terminal pngcairo enhanced font 'Fira Sans,10'
    set autoscale
    set samples 1000
    set output '|kitten icat --stdin yes'
    set object 1 rectangle from screen 0,0 to screen 1,1 fillcolor rgb"#fdf6e3" behind
    plot $@
    set output '/dev/null'
EOF
  }
fi

function nx() {
  npx nx "$@"
}

function ng() {
  npx ng "$@"
}

# Prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# smug tmux session manager completions — macOS only
# (smug is not available in the container; compdef requires compinit which
# hasn't run yet at this point in a non-login shell)
[[ "$(uname)" == "Darwin" ]] && [[ -f ~/.bin/smug.zsh ]] && source ~/.bin/smug.zsh

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# macOS-only: Homebrew sbin
[[ "$(uname)" == "Darwin" ]] && export PATH="/opt/homebrew/sbin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/local/bin:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

fpath=(${HOME}/.zsh_completion.d $fpath)

# macOS-only: Android / Java
if [[ "$(uname)" == "Darwin" ]]; then
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  if [[ -d "$ANDROID_HOME/ndk" ]]; then
    export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk | head -1)"
  fi
fi

export PATH="$PATH:$HOME/go/bin"
export PATH="$HOME/.local/share/mise/shims:$PATH"
export OLLAMA_API_BASE=http://127.0.0.1:11434

export EDITOR=nvim
export AIDER_EDITOR=nvim

# macOS-only: LM Studio
[[ "$(uname)" == "Darwin" ]] && export PATH="$PATH:/Users/ryan/.lmstudio/bin"

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Google Cloud SDK — macOS paths
if [[ "$(uname)" == "Darwin" ]]; then
  [ -f '/Users/ryan/google-cloud-sdk/path.zsh.inc' ] && . '/Users/ryan/google-cloud-sdk/path.zsh.inc'
  # Lazy-load gcloud completions on first tab — sourcing completion.zsh.inc eagerly costs ~500ms
  if [ -f '/Users/ryan/google-cloud-sdk/completion.zsh.inc' ]; then
    _gcloud_lazy_completion() {
      unfunction gcloud gsutil bq 2>/dev/null
      . '/Users/ryan/google-cloud-sdk/completion.zsh.inc'
      compdef _gcloud gcloud
      compdef _gsutil gsutil
      compdef _bq bq
    }
    compdef _gcloud_lazy_completion gcloud gsutil bq
  fi
fi

# Cargo env
[[ "$(uname)" == "Darwin" ]] && [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Docker CLI completions — macOS only
if [[ "$(uname)" == "Darwin" ]]; then
  fpath=(/Users/ryan/.docker/completions $fpath)
fi
autoload -Uz compinit
compinit

# opencode
export PATH=/Users/ryan/.opencode/bin:$PATH

# Secrets — macOS Keychain-backed env vars
if [[ "$(uname)" == "Darwin" ]]; then
  [[ -f ~/.env ]] && source ~/.env
fi

# Force use of rustup tools over everything else — macOS only
[[ "$(uname)" == "Darwin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

# ESP toolchain for Xtensa (ESP32) — macOS only; source if present
[[ "$(uname)" == "Darwin" ]] && [ -f ~/export-esp.sh ] && source ~/export-esp.sh

# mise version manager
export PATH="$HOME/.local/bin:$PATH"
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# Homebrew settings — macOS only
if [[ "$(uname)" == "Darwin" ]]; then
  export HOMEBREW_NO_INSTALL_CLEANUP=1
  export HOMEBREW_NO_AUTO_UPDATE=1
  export HOMEBREW_NO_ENV_HINTS=1
fi

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

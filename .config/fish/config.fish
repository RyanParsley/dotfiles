### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
set --export --prepend PATH "$HOME/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# === Tool Integrations ===
starship init fish | source

# === Environment Variable Management ===
# direnv: automatically load/unload .envrc files per directory
# Install: brew install direnv (macOS), apt install direnv (Linux)
if type -q direnv
  direnv hook fish | source
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH $HOME/.lmstudio/bin

# Machine-specific configuration (not in dotfiles repo)
# Use this file for: API keys, work vs personal configs, machine-specific paths
if test -f ~/.config/fish/config.local.fish
  source ~/.config/fish/config.local.fish
end

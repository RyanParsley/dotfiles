### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/ryan/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
eval "$(/usr/local/bin/rtx activate zsh)"
eval "$(starship init zsh)"

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

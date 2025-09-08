### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/ryan/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export OPENSSL_ROOT_DIR=/usr/local/opt/openssl@3

export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:$(brew --prefix qt@5)
export PATH=$PATH:$(brew --prefix qt@5)/bin

. "$HOME/.local/bin/env"
. "$HOME/.cargo/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/ryan/.lmstudio/bin"
# End of LM Studio CLI section


# User configuration
. "$HOME/.cargo/env"

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export GOPATH=/Users/$USER/go
export PATH=$GOPATH/bin:$PATH
export PATH=$PATH:/opt/homebrew/bin/

eval "$(rtx activate zsh)"

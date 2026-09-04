# User configuration

export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

[[ "$(uname)" == "Darwin" ]] && . "$HOME/.cargo/env"

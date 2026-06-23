# User configuration

export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

[[ "$(uname)" == "Darwin" ]] && . "$HOME/.cargo/env"

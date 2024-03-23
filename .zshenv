# User configuration
. "$HOME/.cargo/env"

export PATH="$(brew --prefix)/opt/openjdk/bin:$PATH"
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
export PATH=$PATH:$(brew --prefix)/bin/


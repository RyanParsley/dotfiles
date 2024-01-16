# A fresh start (sort of)

In an effort to simplify my dotfile game, I've moved to a stow based approach. Clone this repo into ~/.dotfiles and run `stow .` to create some symlinks in the home directory to these file. You'll need to install stow (`brew install stow`) and remove any files in the home directory that you want to be replaced with symlinks manually. 

## Mac only symlink for nushell support
So long as [this is open], you'll need to create a symlink if you want to keep nushell config in your home directory instead of Application Support. I didn't link the folder because I don't want to share history.txt.

```
ln -s ~/.dotfiles/.config/nushell/* `/Users/ryan/Library/Application Support/nushell/`
```

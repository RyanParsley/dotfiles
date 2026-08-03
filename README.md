# A fresh start (sort of)

In an effort to simplify my dotfile game, I've moved to a stow + nix-darwin approach.

## Bootstrap (macOS)

1. Install Nix via the Lix installer:
   ```bash
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```

2. Clone this repo:
   ```bash
   git clone https://codeberg.org/rparsley/dotfiles ~/dotfiles
   ```

3. Bootstrap nix-darwin (first run only):
   ```bash
   sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles
   ```

4. Subsequent rebuilds (stow is now managed by nix):
   ```bash
   just switch
   ```

5. Stow dotfiles:
   ```bash
   just restow
   cd ~/dotfiles && stow ghostty nvim yazi
   ```

## Mac only symlink for nushell support
So long as [this is open], you'll need to create a symlink if you want to keep nushell config in your home directory instead of Application Support. I didn't link the folder because I don't want to share history.txt.

```
ln -s ~/dotfiles/.config/nushell/* "/Users/ryan/Library/Application Support/nushell/"
```

## Pi coding agent runtime

Pi is enabled through nix-darwin and pinned to Nix's Node 22 npm wrapper so native packages like `better-sqlite3` build against a stable ABI.

If you ever change the Pi runtime and see a stale native-addon error again, do a one-time cleanup of the user package cache and restart Pi:

```bash
rm -rf ~/.pi/agent/npm
```

Do not hand-rebuild Pi's `node_modules`; let the Nix-managed wrapper and Pi's own package installer recreate them.

## Agent Skills

Agent Skills ([agentskills.io](https://agentskills.io)) live in `~/.agents/skills/` and work with pi agent, opencode, Claude Code, and more.

### Setup
```bash
# Clone skills repo (user-level, available in all projects)
git clone https://github.com/badlogic/pi-skills ~/.agents/skills/pi-skills
```

Stow handles symlinking `~/.agents/` → `~/dotfiles/.agents/`.

### Updating
```bash
# Pull latest changes
cd ~/.agents/skills/pi-skills && git pull

# Or re-clone from scratch
rm -rf ~/.agents/skills/pi-skills
git clone https://github.com/badlogic/pi-skills ~/.agents/skills/pi-skills
``` 

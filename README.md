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

Pi is enabled through nix-darwin and pinned to Nix's Node runtime so native packages like `better-sqlite3` build against a stable ABI.

Pi configuration is split into mutually exclusive Stow profiles:

- `pi-common` installs shared extensions and project defaults on every machine.
- `pi-home` installs home settings and models. It shows OpenCode and Ollama models and defaults to Qwen on Ollama.
- `~/.dotfiles-local/pi-work` installs private work settings and models. It shows Copilot and Gemma models and defaults to Gemma 4 on Ollama.

`just restow` installs `pi-home` when no work profile is present. `just restow-all` installs `pi-common` and the private `pi-work` profile. Both profiles own `~/.pi/agent/settings.json` and `~/.pi/agent/models.json`, so they must not be installed together.

If you ever change the Pi runtime and see a stale native-addon error again, do a one-time cleanup of the user package cache and restart Pi:

```bash
rm -rf ~/.pi/agent/npm
```

Do not hand-rebuild Pi's `node_modules`; let the Nix-managed wrapper and Pi's own package installer recreate them.

## Agent skills

Agent Skills ([agentskills.io](https://agentskills.io)) work with Pi, OpenCode, Claude Code, and other compatible agents.

`~/.agents/skills/` is an aggregate directory populated by Stow without directory folding:

- `~/dotfiles/.agents/skills/` provides public skills on every machine.
- `~/.dotfiles-local/.agents/skills/` adds private work skills on work machines.

Keeping the aggregate directory separate lets both repositories contribute skills without linking the whole `~/.agents/` directory to either repository. Run `just restow` for public skills or `just restow-all` on a work machine.

Stowed skill files must remain symlinks. If a tool replaces one with a regular file, the same skill can appear once globally and once as a project skill when working in this repository. `just stow-check` and `just check-links` catch this drift.

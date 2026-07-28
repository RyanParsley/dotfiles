# Migrate from Homebrew to nix-darwin

**Branch:** `feature/nix-darwin`  
**Stack:** Nix + nix-darwin + stow (unchanged) + `homebrew.*` residual  
**Goal:** Declarative, reproducible macOS system. Reduce accidental global dependencies. Keep stow for dotfiles.

---

## Philosophy

- Nix best practice: prefer per-project `devShell` / `nix develop` over globals for language runtimes and build tools
- Globals are fine for: daily-driver CLI tools, GUI apps, system daemons, fonts
- Globals are a smell for: language runtimes (use mise), build tools tied to one project (use nix shells), pinned versions of things (use flake inputs)
- Drop anything not intentionally installed — most of the 471 formulae are transitive deps and will not appear in your nix config at all
- `mise` already covers Node, Python, Ruby, Lua, Go version management — do not replicate in nix

---

## Phase 0: Prep

> Sources: [nix-darwin README](https://github.com/nix-darwin/nix-darwin), [Determinate + nix-darwin guide](https://docs.determinate.systems/guides/nix-darwin/) — verified July 2026.

- [x] Create branch `feature/nix-darwin`
- [x] Install Nix. Two options — pick one:

  **Option A: Lix installer** *(recommended by nix-darwin README)*
  ```bash
  curl -sSf -L https://install.lix.systems/lix | sh -s -- install
  ```

  **Option B: Determinate Nix** *(macOS pkg installer — download from docs.determinate.systems)*
  > If using Determinate, you must set `nix.enable = false` in `configuration.nix` to prevent conflict with nix-darwin's Nix config management (see Phase 1 note).

- [x] Verify `/nix/store` exists and `nix --version` works
- [x] Get your hostname: `scutil --get LocalHostName`
- [x] Create `flake.nix` at dotfiles root (see Phase 1)
- [x] Create `darwin/configuration.nix` (see Phase 1)
- [x] Bootstrap nix-darwin (first run only — `darwin-rebuild` not on PATH yet):
  ```bash
  sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles
  ```
- [x] Verify `darwin-rebuild` is now on PATH: `which darwin-rebuild`
- [x] Subsequent runs: `sudo darwin-rebuild switch --flake ~/dotfiles`
- [ ] Add `switch` recipe to `justfile`

---

## Phase 1: Flake Structure

```
~/dotfiles/
├── flake.nix
├── darwin/
│   └── configuration.nix   # system packages, launchd, fonts, homebrew residual
├── justfile                 # add darwin-rebuild recipe
└── ... (stow targets unchanged)
```

Minimal `flake.nix` (replace `your-hostname` with `scutil --get LocalHostName` output):

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ self, nix-darwin, nixpkgs, ... }: {
    darwinConfigurations."your-hostname" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin/configuration.nix ];
    };
  };
}
```

Minimal `darwin/configuration.nix`:

```nix
{ pkgs, ... }: {
  # Required: set platform explicitly (aarch64-darwin for Apple Silicon)
  nixpkgs.hostPlatform = "aarch64-darwin";

  # If using Determinate Nix installer, add this to prevent conflict:
  # nix.enable = false;

  environment.systemPackages = with pkgs; [
    git
    stow
  ];

  system.stateVersion = 7;
}
```

---

## Phase 2: Daily-Driver CLI Tools → `environment.systemPackages`

### Terminal / Shell
- [x] `fish` → `pkgs.fish`
- [x] `nushell` → `pkgs.nushell`
- [x] `starship` → `pkgs.starship`
- [x] `tmux` → `pkgs.tmux`
- [x] `zellij` → `pkgs.zellij`
- [x] `smug` → `pkgs.smug`
- [x] `screen` → `pkgs.screen`

### File / Navigation
- [x] `eza` → `pkgs.eza`
- [x] `fd` → `pkgs.fd`
- [x] `fzf` → `pkgs.fzf`
- [x] `ripgrep` → `pkgs.ripgrep`
- [x] `bat` → `pkgs.bat`
- [x] `bat-extras` → `pkgs.bat-extras`
- [x] `lsd` → `pkgs.lsd`
- [x] `yazi` → `pkgs.yazi`
- [x] `zoxide` → `pkgs.zoxide`
- [x] `sd` → `pkgs.sd`
- [x] `tree` → `pkgs.tree`
- [x] `stow` → `pkgs.stow`

### Git
- [x] `git` → `pkgs.git`
- [x] `git-delta` → `pkgs.delta` *(nixpkgs name differs)*
- [x] `git-cliff` → `pkgs.git-cliff`
- [x] `lazygit` → `pkgs.lazygit`
- [x] `gitleaks` → `pkgs.gitleaks`
- [x] `tig` → `pkgs.tig`
- [x] `lefthook` → `pkgs.lefthook`

### Editors / LSP
- [x] `neovim` → ~~`pkgs.neovim`~~ **skip** — managed by `bob-nvim` (9 versions installed, actively switching). Keep bob as cargo install.
- [ ] `emacs` → `pkgs.emacs` *(not currently installed — add if needed)*
- [x] `lua-language-server` → ~~`pkgs.lua-language-server`~~ **drop global** — Mason owns it
- [x] `typescript-language-server` → ~~`pkgs.typescript-language-server`~~ **drop global** — Mason owns it
- [x] `jdtls` → ~~`pkgs.jdt-language-server`~~ **drop global** — nvim-java plugin manages it
- [x] `stylua` → ~~`pkgs.stylua`~~ **drop global** — Mason owns it; not used in lefthook or CI
- [x] `markdownlint-cli2` → ~~`pkgs.markdownlint-cli2`~~ **drop global** — Mason owns it; not used in lefthook or CI
- [x] `vale` → ~~`pkgs.vale`~~ **drop global** — Mason owns it; not used in lefthook or CI
- [x] `rumdl` → ~~`pkgs.rumdl`~~ **drop global** — Mason owns it; not used in lefthook or CI

### Productivity / TUI
- [x] `htop` → `pkgs.htop`
- [x] `jq` → `pkgs.jq`
- [x] `yq` → `pkgs.yq-go` *(nixpkgs name differs)*
- [x] `frogmouth` → `pkgs.frogmouth`
- [x] `glow` → `pkgs.glow`
- [x] `nap` → `pkgs.nap`
- [x] `nb` → `pkgs.nb`
- [x] `task` → `pkgs.taskwarrior3` *(nixpkgs name differs)*
- [x] `taskwarrior-tui` → `pkgs.taskwarrior-tui`
- [x] `vit` → `pkgs.vit` *(note: nixpkgs `vit` has a hard dependency on `taskwarrior2`, not `taskwarrior3` — basic use works but may use wrong task binary; verify after install)*
- [x] `tldr` → `pkgs.tldr`
- [x] `w3m` → `pkgs.w3m`
- [x] `rich-cli` → `pkgs.rich-cli`
- [x] `chafa` → `pkgs.chafa`
- [x] `viu` → `pkgs.viu`
- [x] `ueberzugpp` → `pkgs.ueberzugpp`

### Docs / Diagramming
- [x] `ack` → `pkgs.ack`
- [x] `cloc` → `pkgs.cloc`
- [x] `tokei` → `pkgs.tokei`
- [x] `d2` → `pkgs.d2`
- [x] `graphviz` → `pkgs.graphviz`
- [x] `gnuplot` → `pkgs.gnuplot`
- [x] `pandoc` → `pkgs.pandoc`
- [x] `mdbook` → `pkgs.mdbook`
- [x] `hugo` → `pkgs.hugo`
- [x] `zola` → `pkgs.zola`
- [x] `zk` → `pkgs.zk`
- [x] `marp-cli` → `pkgs.marp-cli`

### Network / Security
- [x] `curl` → `pkgs.curl`
- [x] `wget` → `pkgs.wget`
- [x] `nmap` → `pkgs.nmap`
- [x] `sq` → `pkgs.sq`
- [x] `caddy` → `pkgs.caddy` *(used by spin-up for multi-worktree reverse proxying)*
- [x] `ttyd` → `pkgs.ttyd`
- [x] `nginx` → ~~`pkgs.nginx`~~ **drop global** — per-project devShell only
- [ ] `gnupg` → `pkgs.gnupg` *(not currently installed — add if needed)*
- [ ] `pinentry` → `pkgs.pinentry` *(not currently installed — add if needed)*

### Media
- [x] `ffmpeg` → `pkgs.ffmpeg`
- [x] `imagemagick` → `pkgs.imagemagick`
- [x] `yt-dlp` → `pkgs.yt-dlp`
- [x] `vhs` → `pkgs.vhs`
- [x] `agg` → `pkgs.agg`
- [x] `asciinema` → `pkgs.asciinema`

### PDF / Viewer
- [x] `zathura` → `pkgs.zathura`
- [x] `zathura-pdf-poppler` → `pkgs.zathura-pdf-poppler`
- [x] `zathura-ps` → `pkgs.zathura-ps`
- [x] `ghostscript` → `pkgs.ghostscript`

---

## Phase 3: Dev Infrastructure → `environment.systemPackages`

### Cross-project tools
- [x] `mise` → `pkgs.mise`
- [x] `just` → `pkgs.just`
- [x] `cocogitto` → `pkgs.cocogitto` *(provides `cog`; used in lefthook commit-msg hooks — not currently in brew, add to nix)*
- [x] `watchexec` → `pkgs.watchexec`
- [x] `scriptisto` → `pkgs.scriptisto`
- [x] `gh` → `pkgs.gh`
- [x] `carapace` → `pkgs.carapace`
- [x] `pngpaste` → `pkgs.pngpaste`

### Containers / Kubernetes
- [x] `docker` → `pkgs.docker`
- [x] `docker-compose` → `pkgs.docker-compose`
- [x] `docker-credential-helper` → `pkgs.docker-credential-helpers`
- [x] `colima` → `pkgs.colima`
- [x] `lima` → `pkgs.lima`
- [x] `kubernetes-cli` → `pkgs.kubectl`
- [x] `helm` → `pkgs.kubernetes-helm`
- [x] `k9s` → `pkgs.k9s`
- [x] `k3d` → `pkgs.k3d`
- [x] `kubeconform` → `pkgs.kubeconform`
- [x] `skaffold` → `pkgs.skaffold`
- [ ] `coder` → `pkgs.coder` *(not currently installed — add if needed)*

### Infra / Cloud
- [x] `terraform` → **drop** — no `.tf` files in Projects, no dependents, dead install
- [x] `azure-cli` → `pkgs.azure-cli`
- [x] `google-cloud-sdk` (cask) → `pkgs.google-cloud-sdk`

### Build tools — drop globals, use per-project devShell

All build tools have been audited. None are used globally:

- [x] `cmake` → **drop global** — all dependents are dead stacks (openvino, spice-gtk, open-mpi) or transitive lib deps
- [x] `ninja` → **drop global** — no dependents
- [x] `gcc` → **drop global** — only depended on by brew rust, which is also being dropped
- [x] `llvm` → **drop global** — only depended on by meson; meson has no dependents
- [x] `meson` → **drop global** — no dependents
- [x] `gradle` → **drop global** — one work Java project; per-project devShell
- [x] `maven` → **drop global** — same work project; per-project devShell

### JS / TS
- [x] `pnpm` → `pkgs.pnpm`
- [x] `deno` → `pkgs.deno`
- [x] `typescript` → ~~`pkgs.nodePackages.typescript`~~ **drop global** — Mason installs ts_ls with its own TypeScript; use `nix shell` for ad-hoc `tsc`
- [x] `node` / `node@24` → ⚠️ **drop globals, use mise**

### Python
- [ ] `pipx` → `pkgs.pipx` *(not currently installed — add if needed)*
- [x] `python@3.12/3.13/3.14` → ⚠️ **drop globals, use mise**
- [x] `pyenv` → ⚠️ **drop, use mise**

### Linters / AI
- [x] `hadolint` → `pkgs.hadolint`
- [x] `llama.cpp` → `pkgs.llama-cpp`
- [x] `opencode` → `pkgs.opencode`
- [x] `promptfoo` → `pkgs.promptfoo`

---

## Phase 4: Fonts → `fonts.packages`

```nix
fonts.packages = with pkgs; [
  nerd-fonts.fantasque-sans-mono
  nerd-fonts.fira-code
  nerd-fonts.jetbrains-mono
  nerd-fonts.symbols-only
  nerd-fonts.victor-mono
];
```

- [x] `font-fantasque-sans-mono-nerd-font` → `pkgs.nerd-fonts.fantasque-sans-mono`
- [x] `font-fira-code-nerd-font` → `pkgs.nerd-fonts.fira-code`
- [x] `font-jetbrains-mono-nerd-font` → `pkgs.nerd-fonts.jetbrains-mono`
- [x] `font-symbols-only-nerd-font` → `pkgs.nerd-fonts.symbols-only`
- [x] `font-victor-mono-nerd-font` → `pkgs.nerd-fonts.victor-mono`

---

## Phase 5: GUI Apps

### Via `environment.systemPackages` (in nixpkgs)
- [ ] `alacritty` → `pkgs.alacritty` *(not installed — add if needed)*
- [x] `ghostty` → `pkgs.ghostty` *(macOS-only; keeping as homebrew.casks — Linux-only in nixpkgs)*
- [ ] `kitty` → `pkgs.kitty` *(not installed — add if needed)*
- [ ] `wezterm` → `pkgs.wezterm` *(not installed — add if needed)*
- [ ] `rio` → `pkgs.rio` *(not installed — add if needed)*
- [ ] `neovide` → `pkgs.neovide` *(not installed — add if needed)*
- [x] `inkscape` → `pkgs.inkscape`
- [x] `obs` → ~~`pkgs.obs-studio`~~ **keep as `homebrew.casks`** — `pkgs.obs-studio` is Linux-only (`meta.platforms` excludes Darwin)
- [ ] `qownnotes` → `pkgs.qownnotes` *(not installed — add if needed)*
- [x] `zettlr` → **drop** — uninstalled, not needed

### Via `homebrew.casks` (not in nixpkgs or macOS-incompatible)
```nix
homebrew = {
  enable = true;
  casks = [ "ghostty" "amethyst" "hiddenbar" "openlens" "basictex" "copilot-cli" ];
  onActivation.cleanup = "zap";
};
```
- [x] `amethyst`
- [x] `hiddenbar`
- [x] `openlens`
- [x] `basictex` (or switch to `pkgs.texlive`)
- [x] `copilot-cli`
- [x] `obs` — `pkgs.obs-studio` is Linux-only; must stay as cask

---

## Phase 6: Homebrew Residual Formulae → `homebrew.brews`

```nix
homebrew.brews = [ "aoe" "zentime" ];
```

- [x] `aoe`
- [x] `repeater` — **drop**: no decks, no config, never set up
- [x] `shelldon` — **drop**: redundant with opencode for AI shell commands
- [x] `zentime` → keep in `homebrew.brews` — config in dotfiles, integrated into zellij layout

Note: `libcuefile`, `libreplaygain`, `libusrsctp`, `latex2rtf`, `aklomp-base64` are
transitive deps — they will not appear in your nix config.

---

## Phase 7: Drop / Audit

| Package | Action | Reason |
|---|---|---|
| `nvm` | **Drop** | mise covers Node |
| `luaver` | **Drop** | mise covers Lua |
| `pyenv` | **Drop** | mise covers Python |
| `ruby-build` | **Drop** | mise internal |
| `rtx` | **Drop** | old name for mise |
| `node` / `node@24` | **Drop globals** | mise per-project |
| `python@3.12/13/14` | **Drop globals** | mise per-project |
| `ruby` | **Drop global** | mise per-project |
| `openjdk` / `openjdk@17` | **Drop globals** | mise or per-project devShell |
| `rust` (brew) | **Drop** | You use rustup from `~/.cargo/bin` — brew rust is redundant and unused |
| `gradle` | **Drop global** | One work Java project (`ws_ordermanagement_order`) — per-project devShell |
| `maven` | **Drop global** | Same work project — per-project devShell |
| `cocoapods` | **Drop** | No `Podfile` found anywhere in Projects. No dependents. |
| `sonarqube` | **Drop** | Server process — you point at remote `sonarqube-prd.jbhunt.com`, not self-hosted |
| `sonar-scanner` | **Drop global** — per-project devShell for `loads_ui` | Work-specific; points at remote corporate instance |
| `mongocli` | **Drop** | No dependents, no project configs, no shell references. Not in nixpkgs anyway. |
- [x] `obs` → ~~`pkgs.obs-studio`~~ keep as `homebrew.casks` — Linux-only package
| `qemu` / `virt-manager` / `libvirt` | **Drop** | No VMs defined, no virt-manager data, empty libvirt config — dead stack. Colima uses macOS Virtualization Framework, not QEMU. |
| `llvm@21` | **Drop** | No dependents. Redundant alongside current `llvm` — likely an upgrade artifact. |
| `ffmpeg@6` | **Drop** | Only depended on by `spice-gtk` (virt-manager stack, also dropped). |
| `openvino` | **Drop** | Only depended on by `spice-gtk` (virt-manager stack, also dropped). Not used on Apple Silicon. |
| `open-mpi` / `pmix` / `prrte` | **Drop** | No dependents; not needed by llama.cpp or openvino. Was likely installed manually during an experiment. |
| `jupyterlab` | **Drop global** | Single exploratory notebook in `hello-jupyter`. Use `nix shell` if needed again. |
| `sphinx-doc` | **Drop** | No Sphinx projects found. No dependents. |
| `gradle-completion` | **Drop** | bundled with gradle in nix |
| `docker-completion` | **Drop** | bundled with docker in nix |
| `bash-completion@2` | **Drop** | handled by nix shell integration |

---

## Phase 8: Shell / PATH Integration

Fish config has been audited. It is clean — no hardcoded `/opt/homebrew/bin`, no brew shellenv call (brew uses `/etc/paths.d/` on Apple Silicon; nix-darwin does the same). Remaining tasks:

- [x] Audit fish config for hardcoded brew paths — none found
- [x] Remove stale Rancher Desktop PATH injection from `config.fish` — done
- [x] Remove `nvm.fish` from `~/.config/fish/conf.d/` once nvm is dropped
- [x] Verify `mise` activation still works post-migration (mise uses `~/.local/share/mise`, PATH-independent)
- [x] Verify colima + docker context works post-migration (colima already active runtime)
- [x] Remove `/private/etc/sudoers.d/zzzzz-rancher-desktop-lima` — stale Rancher Desktop remnant (requires sudo)

---

## Phase 9: Cleanup

- [x] `brew uninstall` each package as its nix equivalent is confirmed working
- [x] `brew autoremove` to clear orphaned transitive deps
- [x] Audit `brew list` until it matches only `homebrew.brews` / `homebrew.casks`
- [x] Update `README.md` with new bootstrap instructions (replace `brew install stow` note)
- [x] Add `switch` recipe to `justfile`:
  ```just
  # Apply nix-darwin configuration
  switch:
      darwin-rebuild switch --flake ~/dotfiles
  ```

---

## Phase 10: Audit cargo-installed tools

Prefer `pkgs.*` over `cargo install`. Fall back to cargo only when nixpkgs has no equivalent.

### Migrate to nix (already in nixpkgs, currently duplicated via cargo)
- [x] `agg` → `pkgs.agg` (drop cargo install)
- [x] `just` → `pkgs.just` (drop cargo install)
- [x] `mdbook` → `pkgs.mdbook` (drop cargo install)
- [x] `cargo-llvm-cov` → `pkgs.cargo-llvm-cov` (drop cargo install)
- [x] `gitui` → `pkgs.gitui` (drop cargo install)
- [x] `bacon` → `pkgs.bacon` (drop cargo install)
- [x] `cargo-nextest` → `pkgs.cargo-nextest` (drop cargo install)
- [x] `cargo-watch` → `pkgs.cargo-watch` (drop cargo install)
- [x] `dprint` → `pkgs.dprint` (drop cargo install)
- [x] `presenterm` → `pkgs.presenterm` (drop cargo install)
- [x] `mprocs` → `pkgs.mprocs` (drop cargo install)
- [x] `wiki-tui` → `pkgs.wiki-tui` (drop cargo install)
- [x] `mdcat` → `pkgs.mdcat` (drop cargo install)
- [x] `sccache` → `pkgs.sccache` (drop cargo install)
- [x] `cocogitto` → `pkgs.cocogitto` (drop cargo install — already in plan)
- [x] `cargo-audit` → `pkgs.cargo-audit` (drop cargo install)
- [x] `cargo-deny` → `pkgs.cargo-deny` (drop cargo install)
- [ ] `wasm-bindgen-cli` → `pkgs.wasm-bindgen-cli` — **keep cargo install** — nixpkgs has 0.2.121, cargo has 0.2.126; must match project's wasm-bindgen crate version exactly
- [x] `trunk` → `pkgs.trunk` (drop cargo install)

### Also migrated to nix (not in original plan, found in nixpkgs)
- [x] `leptosfmt` → `pkgs.leptosfmt` (drop cargo install)
- [x] `dioxus-cli` → `pkgs.dioxus-cli` (drop cargo install)
- [x] `cargo-edit` → `pkgs.cargo-edit` (drop cargo install)
- [x] `cargo-update` → `pkgs.cargo-update` (drop cargo install)
- [x] `cargo-crev` → `pkgs.cargo-crev` (drop cargo install)

### Keep as cargo install (not in nixpkgs or local project paths)
- `mdbook-*` plugins — most not in nixpkgs; keep cargo install
- `bob-nvim` — actively used (9 neovim versions installed, v0.11.5 current). Keep as cargo install. Do NOT put `pkgs.neovim` in nix.
- `leptosfmt` — check nixpkgs first
- `tauri-cli` / `dioxus-cli` / `cargo-tauri` — framework CLIs, check nixpkgs
- `settle`, `scroll`, `rustlings`, `mdbook-frontmatter-table` — local project paths, not publishable to nix
- `evcxr_jupyter`, `evcxr_repl` — Rust Jupyter kernel; nix shell candidate when needed
- `cargo-binstall` — keep as bootstrap tool for the above

### Note on `bob-nvim`
`bob` manages neovim versions. Once `pkgs.neovim` is your neovim source, `bob` is redundant and may conflict. Audit before migrating neovim to nix.

---

## Phase 11: Agent Sandboxing Investigation (post-migration)

**Prerequisite:** nix-darwin migration stable, devenv familiar from at least one real project.

### Architecture

```
devenv.nix           → declares environment (packages, services, processes, git hooks)
devenv container build → produces OCI image (requires Linux builder)
podman run           → rootless execution, network namespace isolation
mitmproxy            → egress control outside the agent process
```

These concerns are orthogonal:
- **devenv** = composition ("what is in the box")
- **Podman** = isolation ("the box is actually a box")
- **mitmproxy** = egress ("the box can't phone home arbitrarily")

### Why not Anthropic's sandbox-runtime

Two complete egress bypasses shipped silently (CVE-2025-66479, SOCKS5 null-byte injection). Both patched with no advisory, no CVE, no user notification. The security boundary is a thin JS wrapper around an obscure npm package at a JS/libc trust boundary. Independent researcher verdict: "The sandbox has been bypassable since it shipped."

The `sandbox.denyRead` setting also does not affect Claude's Read tool — only bash. Reads span the whole filesystem by default.

### Why Podman over Docker

- Rootless by default — no daemon running as root
- OCI-compatible — works with devenv container output
- `podman machine` uses Apple Virtualization Framework on Apple Silicon (same as colima)
- No credential exposure via a privileged daemon socket

### Credential hygiene (the harder problem)

Real credentials must not exist inside the container. The Airut approach:
- Agent gets surrogate/scoped tokens
- mitmproxy swaps in real credentials only for allowlisted hosts
- Real API keys never exist inside the sandbox

### Investigation steps

- [ ] Get devenv working on one project (learn the composition model)
- [ ] Verify `devenv container build` works via `podman machine` on Apple Silicon
- [ ] Evaluate mitmproxy as the egress control layer
- [ ] Prototype: agent runs inside Podman container, egress through mitmproxy allowlist
- [ ] Evaluate libkrun (ERA project) as a lighter alternative to full Podman VM if startup time matters
- [ ] Document findings — either adopt as standard agent workflow or conclude Docker/Podman container is overkill for personal use

### References
- Aonan Guan (Wyze Labs) — sandbox bypass research: oddguan.com
- Airut — rootless Podman + mitmproxy + surrogate tokens (HN)
- Axon — Kubernetes ephemeral pods per agent task (HN)
- ERA — libkrun microVM (~200ms startup) (HN)
- devenv containers: https://devenv.sh/containers/
- devenv Claude Code integration: https://devenv.sh/integrations/claude-code/

---

## Reference: nixpkgs Naming Differences

| brew | nixpkgs attr |
|---|---|
| `git-delta` | `delta` |
| `helm` | `kubernetes-helm` |
| `kubernetes-cli` | `kubectl` |
| `obs` | stays as Homebrew cask — `obs-studio` is Linux-only in nixpkgs |
| `task` | `taskwarrior3` |
| `opus` | `libopus` |
| `webp` | `libwebp` |
| `yq` | `yq-go` |
| `nerd fonts` | `nerd-fonts.<name>` |
| `ffmpeg@6` | `ffmpeg_6` |
| `sdl2` | `SDL2` |
| `sonar-scanner` | `sonar-scanner-cli` |
| `utf8cpp` | `utfcpp` |
| `little-cms2` | `lcms2` |
| `jpeg-turbo` | `libjpeg-turbo` |
| `jpeg-xl` | `libjxl` |

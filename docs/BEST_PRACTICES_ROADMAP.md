# Dotfiles Best Practices Roadmap

This document tracks the modernization and cleanup effort for this dotfiles repository.

**Branch:** `2025-01-06-bestPractices`  
**Started:** January 6, 2026

---

## Completed ✅

### Environment & Version Management
- [x] Introduce direnv for ergonomic environment variable handling
- [x] Remove nvm from fish in favor of mise as standard
- [x] Lazy-load Java path resolution via mise in Neovim

### Documentation
- [x] Create LOCAL_CONFIG.md documenting the `.local` file pattern
- [x] Document security best practices for secrets management
- [x] Add examples for each shell's local config syntax

### Git Workflow
- [x] Enable `pull.rebase = true` for cleaner history
- [x] Enable `push.autoSetupRemote = true` to auto-setup tracking branches

### Code Cleanup
- [x] Remove unused TPM plugin manager from tmux config
- [x] Remove hardcoded Java version and username from Neovim config

---

## High Priority 🔴

### Portability Issues
- [ ] Replace all hardcoded `/Users/ryan/` paths with `$HOME` or `~`
  - [ ] `.config/nushell/config.nu` (lines 966-982, 984, 989)
  - [ ] `.config/nushell/mise.nu` (line 21 - massive PATH string)
  - [ ] `.config/settle/settle.yaml` (line 1)
  - [ ] `.nbrc` (line 16)
  - [ ] `.zshrc` (line 2 - consider moving to .zshrc.local)
  - [ ] `README.md` (line 9 - instructions)

### Configuration Issues
- [ ] Fix duplicate `mise.nu` sourcing in nushell config (sourced 3 times: lines 984, 989, 992)
- [ ] Cache `brew --prefix` once instead of calling 5 times per shell startup
  - [ ] `.zshrc` lines 122, 140-141, 143-144

### Code Cleanup
- [ ] Remove 59 lines of commented oh-my-zsh config from `.zshrc` (lines 6-65)
- [ ] Remove commented code from `.tmux.conf` (lines 36-38, 48-52)
- [ ] Remove old reattach-to-user-namespace workaround (tmux line 52)

---

## Medium Priority 🟡

### TODO Comments
- [ ] Address TODO in `.bin/daily.nu:17` - Implement template-driven file creation
- [ ] Resolve TODO in `nvim/.config/nvim/init.lua:17` - Nushell support issues
- [ ] Address FIXME in `.config/nushell/env.nu:39` - Default implementation
- [ ] Review and address TODOs in nushell completion files (gh, cargo, rustup, cargo-make)

### Gitignore & Cleanup
- [ ] Add missing .gitignore patterns
  - [ ] `*.bak`
  - [ ] `*.swp`, `*.swo`
  - [ ] `*~`, `*.old`
- [ ] Clean up existing .DS_Store files: `find . -name ".DS_Store" -delete`
- [ ] Commit .gitignore improvements

### Shell Consistency
- [ ] Add starship, zoxide, and mise integrations to `.bashrc` (or document why excluded)
- [ ] Set EDITOR consistently across all shell configs
  - [ ] Add to fish config
  - [ ] Add to bash config
- [ ] Create shared aliases file sourced by all shells
  - [ ] Move `nx()`, `ng()`, `iplot` functions to shared location
  - [ ] Move `meeting-note` function to shared location
- [ ] Document shell differences or standardize configurations

### Version Manager Cleanup
- [ ] Choose one version manager format (recommend mise config.toml)
- [ ] Remove redundant `.tool-versions` or `mise/config.toml`
- [ ] Consolidate cargo env loading (currently in .zshenv, .zshrc, .bashrc, nushell/env.nu)

---

## Low Priority 🟢

### PATH Configuration
- [ ] Consolidate 12 separate `export PATH=` statements in .zshrc into single statement
- [ ] Review PATH duplication between .zshrc and .bashrc
- [ ] Document intentional PATH differences between shells
- [ ] Consider creating shared `~/.profile` for common environment variables

### Documentation
- [ ] Expand README.md (currently only 13 lines)
  - [ ] Add reference to LOCAL_CONFIG.md
  - [ ] Document repository structure
  - [ ] List installed tools/dependencies
  - [ ] Improve stow setup instructions
- [ ] Create `docs/INSTALLATION.md` with step-by-step setup guide
- [ ] Create `docs/TOOLS.md` with inventory of all tools
- [ ] Create `docs/SHELLS.md` comparing and documenting each shell setup
- [ ] Document terminal emulator choices (kitty/ghostty/alacritty/rio/wezterm)
- [ ] Document zellij configuration
- [ ] Document yazi configuration
- [ ] Document doom emacs configuration

### Performance Optimization
- [ ] Review oh-my-zsh usage (currently using 11 plugins)
  - [ ] Consider lighter alternatives (zinit/antigen)
  - [ ] Or document why oh-my-zsh is preferred
- [ ] Optimize starship init in nushell (regenerates every shell start)
  - [ ] Only regenerate when starship updates
- [ ] Review nushell completion loading (23 separate source statements)
  - [ ] Consider loop or consolidated sourcing pattern

### File Organization
- [ ] Document primary terminal emulator (multiple configs exist)
- [ ] Consider moving .aider files to subdirectory or ensure fully gitignored
- [ ] Document .amethyst.yml window manager config (9.6KB file)
- [ ] Review .nbrc hardcoded Notes path

### Configuration Cleanup
- [ ] Remove unused nushell prompt functions if starship always used (config.nu lines 5-40)
- [ ] Move Rancher Desktop PATH to machine-specific local config
  - [ ] Update .zshrc and .bashrc managed sections
- [ ] Review commented example aliases in .zshrc (lines 87-89)
- [ ] Clean up commented LDFLAGS export in .zshrc (line 139)

---

## Future Considerations 💭

### Potential Enhancements
- [ ] Consider migrating from oh-my-zsh to lighter plugin manager
- [ ] Evaluate consolidating terminal emulator configs (currently 5 different ones)
- [ ] Consider adding automated tests for dotfiles
- [ ] Add bootstrap script for fresh installations
- [ ] Consider adding pre-commit hooks for checking hardcoded paths

### Template Improvements
- [ ] Implement template-driven approach for daily.nu as noted in TODO
- [ ] Standardize template locations and usage

---

## Statistics

**Commits on branch:** 6  
**Files changed:** 21  
**Lines added:** 405  
**Lines removed:** 437  
**Net change:** -32 lines (cleanup win!)

---

## Notes

- All changes focus on: standardizing version management (mise), better secrets/env management (direnv + local config pattern), performance improvements (lazy-loading), cleaner git workflows, and removing dead code
- Branch is currently clean and ready for continued work
- High priority items focus on portability and performance
- Medium priority items improve maintainability
- Low priority items enhance documentation and user experience

# Local Configuration Files

This dotfiles repository uses a **local config pattern** to separate shared configuration from machine-specific settings.

## What are local config files?

Local config files are **not tracked in git** and contain machine-specific configuration such as:
- API keys and tokens
- Work vs personal environment settings
- Machine-specific paths
- Private aliases and functions
- Credentials

## Local Config Files by Shell

### Zsh
**File:** `~/.zshrc.local`

```zsh
# Example ~/.zshrc.local
export WORK_API_KEY="secret-key-here"
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxx"
export PERSONAL_PROJECTS="$HOME/code/personal"

# Work-specific aliases
alias vpn-work="sudo openconnect vpn.company.com"
```

### Bash
**File:** `~/.bashrc.local`

```bash
# Example ~/.bashrc.local
export WORK_API_KEY="secret-key-here"
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxx"
```

### Fish
**File:** `~/.config/fish/config.local.fish`

```fish
# Example ~/.config/fish/config.local.fish
set -gx WORK_API_KEY "secret-key-here"
set -gx GITHUB_TOKEN "ghp_xxxxxxxxxxxxx"
set -gx PERSONAL_PROJECTS "$HOME/code/personal"
```

### Nushell
**File:** `~/.config/nushell/config.local.nu`

```nushell
# Example ~/.config/nushell/config.local.nu
$env.WORK_API_KEY = "secret-key-here"
$env.GITHUB_TOKEN = "ghp_xxxxxxxxxxxxx"
$env.PERSONAL_PROJECTS = "~/code/personal"
```

## Creating Local Config Files

Local config files are automatically sourced if they exist. To create one:

```bash
# For Zsh
touch ~/.zshrc.local
nvim ~/.zshrc.local

# For Fish
touch ~/.config/fish/config.local.fish
nvim ~/.config/fish/config.local.fish

# For Nushell
touch ~/.config/nushell/config.local.nu
nvim ~/.config/nushell/config.local.nu

# For Bash
touch ~/.bashrc.local
nvim ~/.bashrc.local
```

## What Goes Where?

### ✅ Shared Config (in dotfiles repo)
- Aliases and functions
- Tool integrations (starship, mise, direnv)
- Color schemes and themes
- Key bindings
- Plugin configurations

### ❌ Local Config (NOT in repo, in *.local files)
- API keys and tokens
- Company VPN credentials
- Machine-specific paths
- Work vs personal differentiation
- Proprietary tool configurations

### 🔒 Project-Specific (NOT in repo, use direnv + .envrc)
- Database URLs
- API endpoints
- Development secrets
- Per-project environment variables

## Syncing Between Machines

### Personal ↔️ Work Machine

When setting up on a new machine:

1. **Clone dotfiles:**
   ```bash
   git clone <your-dotfiles-repo> ~/.dotfiles
   cd ~/.dotfiles
   stow .
   ```

2. **Create local config file:**
   ```bash
   # Personal machine
   echo 'export ENV_TYPE="personal"' > ~/.zshrc.local
   
   # Work machine
   echo 'export ENV_TYPE="work"' > ~/.zshrc.local
   echo 'export WORK_VPN="vpn.company.com"' >> ~/.zshrc.local
   ```

3. **Add machine-specific secrets:**
   - Never commit these to the dotfiles repo
   - Use password manager or secure note storage
   - Recreate manually on each machine

## Security Best Practices

1. **Never commit secrets to git:**
   ```bash
   # Check before committing
   git diff
   git status
   ```

2. **Verify .gitignore:**
   ```bash
   # These patterns should be in .gitignore
   *.local
   .env
   .envrc
   ```

3. **Use direnv for project secrets:**
   ```bash
   # In project directory
   echo 'export API_KEY="dev-key"' > .envrc
   direnv allow
   # Add .envrc to project's .gitignore
   ```

4. **Check for accidentally committed secrets:**
   ```bash
   cd ~/.dotfiles
   git log -p | grep -i "password\|secret\|token\|api_key"
   ```

## Example: Different Configurations Per Machine

### ~/.zshrc.local (Personal Mac)
```zsh
export ENV_TYPE="personal"
export GITHUB_TOKEN="ghp_personal_token"
export AWS_PROFILE="personal"

alias code="cd $HOME/code/personal"
```

### ~/.zshrc.local (Work Mac)
```zsh
export ENV_TYPE="work"
export GITHUB_TOKEN="ghp_work_token"
export AWS_PROFILE="company"
export WORK_JIRA_TOKEN="xxx"

alias code="cd $HOME/code/work"
alias vpn="sudo openconnect vpn.company.com"
```

### ~/.zshrc.local (Raspberry Pi)
```zsh
export ENV_TYPE="homelab"
export PI_HOLE_API_KEY="xxx"

alias update-pi="sudo apt update && sudo apt upgrade -y"
```

## Troubleshooting

### Local config not loading?

**Check if file exists:**
```bash
ls -la ~/.zshrc.local
```

**Check file is being sourced in main config:**
```bash
# Should see this in .zshrc:
grep "zshrc.local" ~/.zshrc
```

**Test by sourcing manually:**
```bash
source ~/.zshrc.local
```

### How do I share some local config between machines?

Create a separate **template** in your dotfiles:

```bash
# In dotfiles repo
echo 'export COMMON_SETTING="value"' > .zshrc.local.template

# On each machine
cp ~/.dotfiles/.zshrc.local.template ~/.zshrc.local
# Then add machine-specific settings to ~/.zshrc.local
```

## Related Files

- Main shell configs: `.zshrc`, `.bashrc`, `.config/fish/config.fish`, `.config/nushell/config.nu`
- Git local config: `~/.gitconfig.local` (sourced from `.gitconfig`)
- Tmux local config: `~/.tmux.conf.local` (sourced from `.tmux.conf`)
- Neovim local config: `~/.config/nvim/init-local.lua` (sourced from `init.lua`)

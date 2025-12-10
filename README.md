# Dotfiles

Managed by [Chezmoi](https://chezmoi.io/).

## Machine Profiles

| Profile | Machines | Description |
|---------|----------|-------------|
| `workstation` | main-mac, away-mac | Full dev environment |
| `server` | automation-mac | Core tools, no dev extras |
| `minimal` | hb-mac | PATH + Warp hook only |

## Quick Start

### New Machine

```bash
# Install chezmoi and apply
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply bgadow

# Or with Homebrew
brew install chezmoi
chezmoi init bgadow
chezmoi apply
```

### Update Existing

```bash
chezmoi update
```

### Edit Config

```bash
chezmoi edit ~/.zshrc
chezmoi diff
chezmoi apply
```

## Secrets

Secrets are stored in `~/.env` (not tracked by git). After first apply, edit `~/.env` to add your tokens.

## Files Managed

- `~/.zshrc` - Shell configuration
- `~/.env` - Secrets (templated, not committed)

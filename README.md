# Dotfiles

Managed by [Chezmoi](https://chezmoi.io/).

## Machine Profiles

| Profile | Machines | What gets synced |
|---------|----------|------------------|
| \`workstation\` | main-mac, away-mac | Everything - shell, Claude, Brewfile, LaunchAgents |
| \`server\` | automation-mac | Shell, Brewfile, LaunchAgents (no Claude settings) |
| \`minimal\` | hb-mac | Just .zshrc basics |

## Files Managed

| File | Description |
|------|-------------|
| \`~/.zshrc\` | Shell configuration |
| \`~/.env\` | Secrets (created once, not overwritten) |
| \`~/.claude/settings.json\` | Claude Code settings |
| \`~/.claude/settings.local.json\` | Claude permissions (created once) |
| \`~/.claude/statusline.sh\` | Custom statusline script |
| \`~/.Brewfile\` | Homebrew packages |
| \`~/Library/LaunchAgents/com.chezmoi.update.plist\` | Daily update job |

## Quick Start

### New Machine

\`\`\`bash
# Install chezmoi and apply
sh -c "\$(curl -fsLS get.chezmoi.io)" -- init --apply KahunaCodes/dotfiles-chezmoi

# Or with Homebrew (workstation/server)
brew install chezmoi
chezmoi init KahunaCodes/dotfiles-chezmoi --apply

# Then populate ~/.env with your secrets
\`\`\`

### Update Existing

\`\`\`bash
chezmoi update
\`\`\`

## Day-to-Day Usage

\`\`\`bash
# Edit a managed file
chezmoi edit ~/.zshrc

# See what would change
chezmoi diff

# Apply changes locally
chezmoi apply

# Push updates to repo
chezmoi cd && git add -A && git commit -m "update" && git push
\`\`\`

## Homebrew Package Sync

The Brewfile is synced. When it changes, \`brew bundle\` runs automatically.

To update the Brewfile after installing new packages:
\`\`\`bash
brew bundle dump --file=~/.Brewfile --force
chezmoi add ~/.Brewfile
chezmoi cd && git add -A && git commit -m "Update Brewfile" && git push
\`\`\`

## What Chezmoi Does NOT Manage

- **nvm/pyenv versions**: These tools download interpreters at runtime. Chezmoi ensures your shell loads them, but you install versions manually (\`nvm install 20\`, \`pyenv install 3.12\`)
- **npm global packages**: Install manually on each machine
- **Runtime data**: ~/.claude/history.json, logs, todos, etc.

## Secrets

Secrets live in \`~/.env\` which is created once and never overwritten. After first apply:
1. Edit \`~/.env\`
2. Add your tokens (GITHUB_TOKEN, TRELLO, SLACK, etc.)
3. Run \`source ~/.zshrc\` or open new terminal

## Auto Updates

A LaunchAgent runs \`chezmoi update\` daily at 9am. Check logs:
\`\`\`bash
cat /tmp/chezmoi-update.log
cat /tmp/chezmoi-update.err
\`\`\`

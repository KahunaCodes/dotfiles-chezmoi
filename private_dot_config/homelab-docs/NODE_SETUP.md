# Node.js Setup Guide

## Strategy: NVM (Node Version Manager)

We use NVM instead of Homebrew's node because:
- **Version pinning**: Use `.nvmrc` files per project
- **Isolation**: Brew updates won't break node projects
- **Flexibility**: Easy switching between versions
- **Consistency**: Same setup across all machines

## Installation

### 1. Remove Brew Node (if installed)
```bash
brew uninstall node node@20 node@22 2>/dev/null
brew autoremove
```

### 2. Install NVM
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

### 3. Reload Shell
```bash
source ~/.zshrc
# Or open a new terminal
```

### 4. Install Node LTS
```bash
nvm install 22    # Current LTS
nvm alias default 22
```

### 5. Install Standard Global Packages
```bash
# MCP Servers (for Claude Code)
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-memory
npm install -g @modelcontextprotocol/server-github
npm install -g @playwright/mcp

# Tools
npm install -g @linear/cli
npm install -g @21st-dev/magic

# Optional but useful
npm install -g @modelcontextprotocol/server-sequential-thinking
```

## Machine Status

| Machine | NVM | Node | Status |
|---------|-----|------|--------|
| main-mac | ✅ | v22.x | Reference setup |
| automation-mac | ✅ | v22.x | Production bot |
| away-mac | ✅ | v22.x | Mobile dev |
| hb-mac | ✅ | v22.x | Backup |

## Troubleshooting

### "nvm: command not found"
Ensure these lines are in ~/.zshrc:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
```

### npm can't find packages
```bash
nvm use default
npm config set prefix ~/.nvm/versions/node/$(node -v)
```

## Maintenance

### Update Node
```bash
nvm install 22 --reinstall-packages-from=current
nvm alias default 22
```

### Update NVM
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

---
*Last updated: December 2024*
*Managed via chezmoi - syncs to all machines*

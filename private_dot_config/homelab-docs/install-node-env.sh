#!/bin/bash
set -e
echo "Node.js Environment Setup"
echo "========================="

# Remove brew node if present
if command -v /opt/homebrew/bin/brew > /dev/null; then
    brew list node > /dev/null 2>&1 && brew uninstall node || true
    brew list node@20 > /dev/null 2>&1 && brew uninstall node@20 || true
    brew list node@22 > /dev/null 2>&1 && brew uninstall node@22 || true
    brew autoremove 2>/dev/null || true
fi

# Install NVM
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Install Node LTS
nvm install 22 && nvm alias default 22 && nvm use default

# Install global packages
npm i -g @modelcontextprotocol/server-filesystem @modelcontextprotocol/server-memory
npm i -g @modelcontextprotocol/server-github @playwright/mcp @linear/cli @21st-dev/magic

echo "Done! Node $(node -v), NPM $(npm -v)"

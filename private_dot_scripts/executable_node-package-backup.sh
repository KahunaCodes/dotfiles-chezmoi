#!/bin/bash

# Create backup directory with timestamp
BACKUP_DIR="$HOME/node-migration-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating comprehensive Node/npm package backup in: $BACKUP_DIR"
echo "=================================================="

# 1. Global NPM packages (current system)
echo "Backing up global NPM packages..."
npm list -g --depth=0 > "$BACKUP_DIR/npm-global-packages.txt" 2>&1
npm list -g --json > "$BACKUP_DIR/npm-global-packages.json" 2>&1

# 2. Get more detailed info about global packages
echo "Getting detailed global package info..."
npm list -g --depth=0 --json | jq -r '.dependencies | keys[]' 2>/dev/null > "$BACKUP_DIR/npm-global-names-only.txt" || \
  npm list -g --depth=0 | grep -E "├──|└──" | sed 's/├──\|└──//g' | awk '{print $1}' > "$BACKUP_DIR/npm-global-names-only.txt"

# 3. Homebrew packages (Node-related)
echo "Backing up Homebrew Node-related packages..."
brew list | grep -E "(node|npm|yarn|pnpm|bun)" > "$BACKUP_DIR/brew-node-related.txt" 2>&1
brew list --versions | grep -E "(node|npm|yarn|pnpm|bun)" > "$BACKUP_DIR/brew-node-versions.txt" 2>&1

# 4. Check for yarn global packages (if yarn is installed)
if command -v yarn &> /dev/null; then
    echo "Backing up Yarn global packages..."
    yarn global list --depth=0 > "$BACKUP_DIR/yarn-global-packages.txt" 2>&1
fi

# 5. Check for pnpm global packages (if pnpm is installed)
if command -v pnpm &> /dev/null; then
    echo "Backing up pnpm global packages..."
    pnpm list -g --depth=0 > "$BACKUP_DIR/pnpm-global-packages.txt" 2>&1
fi

# 6. System information
echo "Backing up system Node/npm info..."
{
    echo "System Information Backup"
    echo "========================"
    echo ""
    echo "Date: $(date)"
    echo ""
    echo "Node version: $(node --version 2>&1)"
    echo "Node location: $(which node 2>&1)"
    echo ""
    echo "npm version: $(npm --version 2>&1)"
    echo "npm location: $(which npm 2>&1)"
    echo ""
    echo "npm prefix: $(npm prefix -g 2>&1)"
    echo "npm root: $(npm root -g 2>&1)"
    echo ""
    echo "PATH variable:"
    echo "$PATH" | tr ':' '\n' | nl
    echo ""
    echo "Node-related environment variables:"
    env | grep -E "(NODE|NPM|NVM)" | sort
} > "$BACKUP_DIR/system-info.txt"

# 7. Create reinstall scripts
echo "Creating reinstall helper scripts..."

# Create npm reinstall script
if [ -f "$BACKUP_DIR/npm-global-names-only.txt" ]; then
    echo "#!/bin/bash" > "$BACKUP_DIR/npm-reinstall-globals.sh"
    echo "# Auto-generated npm global package reinstall script" >> "$BACKUP_DIR/npm-reinstall-globals.sh"
    echo "# Review this list and remove packages you don't need!" >> "$BACKUP_DIR/npm-reinstall-globals.sh"
    echo "" >> "$BACKUP_DIR/npm-reinstall-globals.sh"
    echo "packages=(" >> "$BACKUP_DIR/npm-reinstall-globals.sh"
    while IFS= read -r package; do
        # Skip npm itself and empty lines
        if [[ ! "$package" =~ ^npm@ ]] && [[ -n "$package" ]]; then
            echo "  \"$package\"" >> "$BACKUP_DIR/npm-reinstall-globals.sh"
        fi
    done < "$BACKUP_DIR/npm-global-names-only.txt"
    echo ")" >> "$BACKUP_DIR/npm-reinstall-globals.sh"
    echo "" >> "$BACKUP_DIR/npm-reinstall-globals.sh"
    echo "for package in \"\${packages[@]}\"; do" >> "$BACKUP_DIR/npm-reinstall-globals.sh"
    echo "  echo \"Installing \$package...\"" >> "$BACKUP_DIR/npm-reinstall-globals.sh"
    echo "  npm install -g \"\$package\"" >> "$BACKUP_DIR/npm-reinstall-globals.sh"
    echo "done" >> "$BACKUP_DIR/npm-reinstall-globals.sh"
    chmod +x "$BACKUP_DIR/npm-reinstall-globals.sh"
fi

# 8. Create a summary report
{
    echo "Node/NPM Migration Backup Summary"
    echo "================================="
    echo ""
    echo "Backup created at: $(date)"
    echo "Backup location: $BACKUP_DIR"
    echo ""
    echo "Current Setup:"
    echo "- Node: $(node --version 2>&1) at $(which node 2>&1)"
    echo "- npm: $(npm --version 2>&1) at $(which npm 2>&1)"
    echo ""
    echo "Global packages found:"
    echo "- npm: $(wc -l < "$BACKUP_DIR/npm-global-names-only.txt" 2>/dev/null || echo "0") packages"
    [ -f "$BACKUP_DIR/yarn-global-packages.txt" ] && echo "- yarn: $(grep -c "info" "$BACKUP_DIR/yarn-global-packages.txt" 2>/dev/null || echo "0") packages"
    [ -f "$BACKUP_DIR/pnpm-global-packages.txt" ] && echo "- pnpm: $(grep -c "│" "$BACKUP_DIR/pnpm-global-packages.txt" 2>/dev/null || echo "0") packages"
    echo ""
    echo "Files created:"
    ls -la "$BACKUP_DIR"
} > "$BACKUP_DIR/SUMMARY.txt"

echo ""
echo "✅ Backup complete!"
echo ""
echo "📁 All files saved to: $BACKUP_DIR"
echo ""
echo "Key files:"
echo "  - SUMMARY.txt: Overview of your setup"
echo "  - npm-global-names-only.txt: Simple list of global package names"
echo "  - npm-reinstall-globals.sh: Script to reinstall packages after migration"
echo "  - system-info.txt: Detailed system configuration"
echo ""
echo "Next steps:"
echo "1. Review the package lists and identify what you actually need"
echo "2. Most packages should be project-local, not global"
echo "3. Edit npm-reinstall-globals.sh to keep only essential CLI tools"
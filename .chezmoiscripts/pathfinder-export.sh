#!/bin/bash
# Path Finder Settings Export Script
# Run this manually to capture current settings before committing
# Usage: ~/.local/share/chezmoi/.chezmoiscripts/pathfinder-export.sh

set -e

CHEZMOI_SOURCE="${CHEZMOI_SOURCE_DIR:-$(chezmoi source-path)}"
PF_CHEZMOI_DIR="$CHEZMOI_SOURCE/private_Library/private_Application Support/private_Path Finder"
PF_SUPPORT_DIR="$HOME/Library/Application Support/Path Finder"
PF_PREFS_DIR="$CHEZMOI_SOURCE/.chezmoitemplates"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Path Finder Settings Export${NC}"
echo "=============================="

# Check if Path Finder is running
if pgrep -x "Path Finder" > /dev/null; then
    echo -e "${RED}⚠️  Path Finder is running. Please quit it first to ensure settings are flushed.${NC}"
    read -p "Quit Path Finder now and press Enter to continue, or Ctrl+C to abort..."
    
    if pgrep -x "Path Finder" > /dev/null; then
        echo -e "${RED}Path Finder still running. Aborting.${NC}"
        exit 1
    fi
fi

# Create directories
mkdir -p "$PF_CHEZMOI_DIR/Settings"
mkdir -p "$PF_PREFS_DIR"

# Export plist via defaults (cfprefsd-safe)
echo -e "${GREEN}📦 Exporting preferences plist...${NC}"
defaults export com.cocoatech.PathFinder "$PF_PREFS_DIR/pathfinder-prefs.plist"

# Copy SQLite settings database
echo -e "${GREEN}📦 Copying settings database...${NC}"
if [ -f "$PF_SUPPORT_DIR/Settings/settings10" ]; then
    # Use sqlite3 to create a clean copy (handles WAL mode properly)
    sqlite3 "$PF_SUPPORT_DIR/Settings/settings10" "VACUUM INTO '$PF_CHEZMOI_DIR/Settings/settings10'"
    echo "  ✓ settings10 database copied"
else
    echo -e "${YELLOW}  ⚠️ settings10 not found${NC}"
fi

# Copy Searches (smart folders)
echo -e "${GREEN}📦 Copying saved searches...${NC}"
if [ -d "$PF_SUPPORT_DIR/Searches" ]; then
    cp -R "$PF_SUPPORT_DIR/Searches" "$PF_CHEZMOI_DIR/"
    echo "  ✓ Searches copied"
fi

echo ""
echo -e "${GREEN}✅ Export complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review changes: chezmoi diff"
echo "  2. Add to git: cd $(chezmoi source-path) && git add -A && git commit -m 'Update Path Finder settings'"
echo "  3. Push: git push"

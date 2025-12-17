#!/bin/bash
# excel-export.sh - Export VBA macros from PERSONAL.XLSB to files
# Requires: Microsoft Excel, PERSONAL.XLSB with ExportAllVbaCode macro

set -e

PERSONAL_XLSB_PATH="$HOME/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Excel/PERSONAL.XLSB"
MACRO_NAME="ExportAllVbaCode"

echo "🚀 Starting VBA export..."

# Check if Excel is running, start it if not
if ! pgrep -x "Microsoft Excel" > /dev/null; then
    echo "Starting Excel..."
    open -a "Microsoft Excel"
    sleep 3
fi

# Run the macro with error checking
if osascript -e "tell application \"Microsoft Excel\"" \
    -e "open \"${PERSONAL_XLSB_PATH}\"" \
    -e "run VB macro \"${MACRO_NAME}\"" \
    -e "end tell" 2>&1; then
    
    echo "✅ VBA export successful"
    
    # Git operations (if in a git repo)
    if git rev-parse --git-dir > /dev/null 2>&1; then
        cd "$(dirname "$0")"
        
        if [[ -n $(git status -s excel-vba-macros/ 2>/dev/null) ]]; then
            git add excel-vba-macros/
            git commit -m "feat(vba): sync excel macros - $(date '+%Y-%m-%d %H:%M:%S')"
            git push
            echo "✅ Changes pushed to Git"
        else
            echo "ℹ️  No changes to commit"
        fi
    fi
else
    echo "❌ VBA export failed"
    exit 1
fi

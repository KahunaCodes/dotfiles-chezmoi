# Path Finder Settings Sync

This directory contains Path Finder settings synced via chezmoi.

## What's Synced

| File/Directory | Purpose |
|----------------|---------|
| `.chezmoitemplates/pathfinder-prefs.plist` | Main preferences (exported via `defaults`) |
| `Settings/settings10` | SQLite database with layouts, browsers, UI state |
| `Searches/` | Saved smart searches |

## How It Works

1. **Export** (on source machine): Run `.chezmoiscripts/pathfinder-export.sh`
   - Quit Path Finder first
   - Exports plist via `defaults export` (cfprefsd-safe)
   - Copies SQLite database with proper WAL handling
   
2. **Import** (on target machine): Automatic via `run_onchange_after_pathfinder-sync.sh.tmpl`
   - Triggered when plist hash changes
   - Imports via `defaults import`
   - Copies database (only if Path Finder not running)

## Manual Sync

```bash
# Export current settings
~/.local/share/chezmoi/.chezmoiscripts/pathfinder-export.sh

# Commit and push
cd ~/.local/share/chezmoi
git add -A && git commit -m "Update Path Finder settings"
git push

# On other machines
chezmoi update
```

## Notes

- Always quit Path Finder before export/import
- The SQLite database won't update if Path Finder is running
- Preferences plist updates take effect after Path Finder restart

# Global Claude Code Configuration

## SuperClaude Framework
@COMMANDS.md
@FLAGS.md
@PRINCIPLES.md
@RULES.md
@MCP.md
@PERSONAS.md
@ORCHESTRATOR.md
@MODES.md

## Development Practices

### Python
- **Use `uv` for all Python operations** (not pip/venv directly)
  - Create venv: `uv venv` (not `python -m venv`)
  - Install packages: `uv add <package>` or `uv pip install`
  - Run scripts: `uv run python script.py` (auto-syncs deps)
  - Pin Python version: `uv python pin 3.13`
  - Initialize project: `uv init .` (creates pyproject.toml + .python-version)
- Always use `/.venv` (not `/venv`) - uv creates this by default
- Check for `.python-version` file before assuming Python version
- For existing projects with requirements.txt: `uv pip install -r requirements.txt`
- Test imports before complex implementations
- Test incrementally, not after everything is built

### Git Workflow
- Commit after completing each task step
- Push after committing, then verify no uncommitted changes
- Use descriptive commit messages

### MCP Usage
- Use Serena when available for semantic code retrieval
- Use Context7 for up-to-date third-party documentation
- Use Sequential Thinking for complex decisions
- **DO NOT use apple-reminders or apple-mcp servers** - they are broken

### Apple Reminders (via CLI, not MCP)
The MCP reminders servers don't work. Use `~/bin/reminders-cli` via shell instead:
```bash
# List all reminder lists
~/bin/reminders-cli --action read-lists

# Read reminders (with optional filters)
~/bin/reminders-cli --action read
~/bin/reminders-cli --action read --dueWithin today
~/bin/reminders-cli --action read --dueWithin overdue
~/bin/reminders-cli --action read --filterList "Tasks"
~/bin/reminders-cli --action read --search "keyword"

# Create reminder
~/bin/reminders-cli --action create --title "Task name" --targetList "Tasks"
~/bin/reminders-cli --action create --title "Due tomorrow" --targetList "Personal" --dueDate "2025-12-20"

# Update reminder (mark complete)
~/bin/reminders-cli --action update --id "UUID" --isCompleted true

# Delete reminder
~/bin/reminders-cli --action delete --id "UUID"
```

### General
- Read project CLAUDE.md before starting work
- Don't make assumptions on how to navigate sites
- Back up claims with evidence and official docs

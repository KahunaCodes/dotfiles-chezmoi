#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Debug mode - uncomment next line to enable debug output to a log file
DEBUG_LOG="$HOME/.claude/statusline-debug.log"

# Debug function
debug_log() {
    if [ -n "$DEBUG_LOG" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$DEBUG_LOG"
    fi
}

# Function to count todos from various sources
count_todos() {
    local todos=0
    local transcript_path=$(echo "$input" | jq -r '.transcript_path // ""' 2>/dev/null)
    local session_id=$(echo "$input" | jq -r '.session_id // ""' 2>/dev/null)
    
    debug_log "Session ID: $session_id"
    debug_log "Transcript path: $transcript_path"
    
    # Method 1: Check transcript file for todo patterns
    if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        debug_log "Checking transcript file for todos"
        
        # Look for the most recent TodoWrite tool call result
        local todo_write_result=$(grep -A 20 "TodoWrite" "$transcript_path" | grep -E "^\s*\[.*\{.*\"status\".*\"pending\"" | tail -1)
        
        if [ -n "$todo_write_result" ]; then
            # Try to parse the JSON array of todos
            todos=$(echo "$todo_write_result" | jq '[.[] | select(.status == "pending")] | length' 2>/dev/null || echo 0)
            debug_log "Found todos from TodoWrite result: $todos"
        fi
        
        # Alternative: look for recent todo patterns in conversation
        if [ $todos -eq 0 ]; then
            # Count pending todos from recent messages
            local pending_mentions=$(grep -c "pending\|📋" "$transcript_path" 2>/dev/null || echo 0)
            local status_pending=$(grep -c "\"status\".*\"pending\"" "$transcript_path" 2>/dev/null || echo 0)
            
            # Use the higher count, but cap at a reasonable number
            todos=$(( status_pending > pending_mentions ? status_pending : pending_mentions ))
            if [ $todos -gt 20 ]; then
                todos=20  # Cap at reasonable limit
            fi
            
            debug_log "Found todos from conversation patterns: $todos"
        fi
        
        # Look for todo list in recent messages (more specific pattern)
        if [ $todos -eq 0 ] || [ $todos -gt 10 ]; then
            # Look for actual todo list structures
            local todo_list_count=$(awk '/## (Current Tasks|Todo|Pending)/{flag=1; next} /^##/{flag=0} flag && /^\s*[0-9]+\.|\*|\-/{count++} END{print count+0}' "$transcript_path" 2>/dev/null || echo 0)
            
            if [ $todo_list_count -gt 0 ] && [ $todo_list_count -lt 15 ]; then
                todos=$todo_list_count
                debug_log "Found todos from structured list: $todos"
            fi
        fi
    fi
    
    # Method 2: Check for todo files in various locations
    if [ $todos -eq 0 ]; then
        debug_log "Checking todo files"
        
        local todo_files=(
            "$HOME/.claude/todos/$session_id.json"
            "$HOME/.claude/sessions/$session_id/todos.json"
            ".claude/todos.json"
            ".claude/todos/current.json"
            "$HOME/.claude/todos/current.json"
            "$HOME/.claude/conversations/$session_id/todos.json"
        )
        
        for todo_file in "${todo_files[@]}"; do
            if [ -f "$todo_file" ]; then
                debug_log "Found todo file: $todo_file"
                
                # Try to count pending todos using jq
                local count=$(jq -r 'if type == "array" then [.[] | select(.status == "pending")] | length else 0 end' "$todo_file" 2>/dev/null || echo 0)
                if [ "$count" -gt 0 ]; then
                    todos=$count
                    debug_log "Counted todos from JSON: $todos"
                    break
                fi
                
                # Fallback to grep for JSON-like patterns
                local grep_count=$(grep -c '"status"[[:space:]]*:[[:space:]]*"pending"' "$todo_file" 2>/dev/null || echo 0)
                if [ "$grep_count" -gt 0 ]; then
                    todos=$grep_count
                    debug_log "Counted todos from grep: $todos"
                    break
                fi
            fi
        done
    fi
    
    # Method 3: Last resort - check current directory for any Claude-related todo files
    if [ $todos -eq 0 ]; then
        debug_log "Checking current directory for todos"
        
        # Look for any .claude or todo-related files in current directory
        local local_todo_files=(
            ".claude/todos.json"
            ".claude/current-todos.json" 
            ".claude/session-todos.json"
            "todos.json"
            ".todos.json"
        )
        
        for file in "${local_todo_files[@]}"; do
            if [ -f "$file" ]; then
                debug_log "Found local todo file: $file"
                local count=$(jq -r 'if type == "array" then [.[] | select(.status == "pending")] | length else if type == "object" then if has("todos") then [.todos[] | select(.status == "pending")] | length else 0 end else 0 end end' "$file" 2>/dev/null || echo 0)
                if [ "$count" -gt 0 ]; then
                    todos=$count
                    debug_log "Found todos in local file: $todos"
                    break
                fi
            fi
        done
    fi
    
    # Method 4: Check if JSON input has any todo-related data
    if [ $todos -eq 0 ]; then
        debug_log "Checking input JSON for todo data"
        # Log the input JSON structure for debugging
        debug_log "Input JSON keys: $(echo "$input" | jq -r 'keys[]' 2>/dev/null | tr '\n' ' ')"
        
        # Check various possible todo fields in input JSON
        local json_todos=$(echo "$input" | jq -r '.todos // .pending_todos // .task_count // .todo_count // 0' 2>/dev/null || echo 0)
        if [ "$json_todos" -gt 0 ]; then
            todos=$json_todos
            debug_log "Found todos in input JSON: $todos"
        fi
    fi
    
    debug_log "Final todo count: $todos"
    echo $todos
}

# Get project information
PROJECT=$(basename "$PWD")
WORKSPACE_DIR=$(echo "$input" | jq -r '.workspace.current_dir // ""' 2>/dev/null)
if [ -n "$WORKSPACE_DIR" ]; then
    PROJECT=$(basename "$WORKSPACE_DIR")
fi

# Get model information
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"' 2>/dev/null || echo "Claude")

# Count todos
TODOS=$(count_todos)

# Get output style for additional context
OUTPUT_STYLE=$(echo "$input" | jq -r '.output_style.name // ""' 2>/dev/null)

# Build statusline
STATUSLINE="🚀 $PROJECT | 📝 $TODOS todos | ⚡ $MODEL"

# Add output style if available and not default
if [ -n "$OUTPUT_STYLE" ] && [ "$OUTPUT_STYLE" != "default" ]; then
    STATUSLINE="$STATUSLINE | 🎨 $OUTPUT_STYLE"
fi

echo "$STATUSLINE"
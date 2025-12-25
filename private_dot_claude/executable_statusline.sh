#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# --- Colors ---
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Foreground colors
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'

# Bright colors
BRIGHT_RED='\033[91m'
BRIGHT_GREEN='\033[92m'
BRIGHT_YELLOW='\033[93m'
BRIGHT_BLUE='\033[94m'

# 256-color for orange
ORANGE='\033[38;5;214m'

# --- Directory Name ---
get_dir_name() {
    local workspace_dir
    workspace_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""' 2>/dev/null)
    if [ -n "$workspace_dir" ]; then
        basename "$workspace_dir"
    else
        basename "$PWD"
    fi
}

# --- Git Info ---
get_git_info() {
    # Check if in a git repo
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        return
    fi

    # Repo name (from remote or directory)
    local repo_name
    repo_name=$(basename -s .git "$(git config --get remote.origin.url 2>/dev/null)" 2>/dev/null)
    if [ -z "$repo_name" ]; then
        repo_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    fi

    # Branch name
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    # Dirty indicator
    local dirty=""
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        dirty="${BRIGHT_YELLOW}*${RESET}"
    fi

    # Staged/unstaged counts
    local staged unstaged stage_info=""
    staged=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    unstaged=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    if [ "$staged" -gt 0 ] || [ "$unstaged" -gt 0 ]; then
        stage_info=" ${GREEN}+${staged}${RESET}${RED}-${unstaged}${RESET}"
    fi

    # Ahead/behind remote
    local ahead behind remote_info=""
    ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
    behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)
    if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
        remote_info=" ${CYAN}↑${ahead}${RESET}${MAGENTA}↓${behind}${RESET}"
    fi

    echo -e "${BLUE}${repo_name}${RESET}/${BRIGHT_BLUE}${branch}${RESET}${dirty}${stage_info}${remote_info}"
}

# --- Context Remaining ---
get_context_info() {
    local input_tokens output_tokens tokens_used tokens_max pct color

    # Get tokens from context_window object
    input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0' 2>/dev/null)
    output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0' 2>/dev/null)
    tokens_max=$(echo "$input" | jq -r '.context_window.context_window_size // 200000' 2>/dev/null)

    tokens_used=$((input_tokens + output_tokens))

    if [ "$tokens_used" -gt 0 ] && [ "$tokens_max" -gt 0 ]; then
        pct=$(( 100 - (tokens_used * 100 / tokens_max) ))

        # Color based on context remaining
        if [ "$pct" -ge 60 ]; then
            color=$BRIGHT_GREEN
        elif [ "$pct" -ge 30 ]; then
            color=$BRIGHT_YELLOW
        elif [ "$pct" -ge 15 ]; then
            color=$YELLOW
        else
            color=$BRIGHT_RED
        fi

        echo -e "${color}${pct}%${RESET} ctx"
    fi
}

# --- Model ---
get_model() {
    local model short_model
    model=$(echo "$input" | jq -r '.model.display_name // .model.name // .model // ""' 2>/dev/null)

    # Shorten common model names
    case "$model" in
        *[Oo]pus*4.5*|*4.5*[Oo]pus*) short_model="opus-4.5" ;;
        *[Oo]pus*) short_model="opus" ;;
        *[Ss]onnet*) short_model="sonnet" ;;
        *[Hh]aiku*) short_model="haiku" ;;
        "") return ;;
        *) short_model="$model" ;;
    esac

    echo -e "${ORANGE}${short_model}${RESET}"
}

# --- Build Statusline ---
DIR_NAME="${BOLD}${WHITE}$(get_dir_name)${RESET}"
GIT_INFO=$(get_git_info)
CTX_INFO=$(get_context_info)
MODEL=$(get_model)

# Separator
SEP="${DIM}|${RESET}"

# Assemble parts with proper separators
PARTS=()
[ -n "$DIR_NAME" ] && PARTS+=("$DIR_NAME")
[ -n "$GIT_INFO" ] && PARTS+=("$GIT_INFO")
[ -n "$CTX_INFO" ] && PARTS+=("$CTX_INFO")
[ -n "$MODEL" ] && PARTS+=("$MODEL")

# Join with separator
printf '%b' "${PARTS[0]}"
for part in "${PARTS[@]:1}"; do
    printf ' %b %b' "$SEP" "$part"
done
echo

# Debug: uncomment to log input to file
# echo "$input" >> ~/.claude/statusline-debug.log

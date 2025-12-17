#!/bin/bash

# --- Configuration ---
# Set the number of parallel ffmpeg processes to run
NUM_PROCESSES=4
SCAN_DIR="${1:-/Volumes/vault-new/Extras/Sort/}"
LOG_FILE="${SCAN_DIR}/corrupted_files.log"

# 1. DEFINE THE FUNCTION
# This function contains the logic to check a SINGLE file.
# xargs will call this function for each file it processes.
check_file() {
  local file_to_check="$1"
  local tmp_log

  tmp_log=$(mktemp)

  # Run the ffmpeg check on the specific file passed to the function.
  ffmpeg -v error -i "$file_to_check" -f null - 2> "$tmp_log"

  # If the temp log is not empty, an error occurred.
  if [ -s "$tmp_log" ]; then
    echo "$file_to_check" >> "$LOG_FILE"
  fi

  rm -f "$tmp_log"
}

# 2. PREPARE FOR THE RUN
export -f check_file
export LOG_FILE

# Clear the log file from any previous run.
> "$LOG_FILE"

echo "Starting parallel scan with $NUM_PROCESSES processes..."
echo "Scanning: $SCAN_DIR"
echo "Corrupted files will be logged to: $LOG_FILE"

# 3. EXECUTE THE PARALLEL SCAN
find "$SCAN_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" \) -print0 | \
  xargs -0 -P "$NUM_PROCESSES" -I {} bash -c 'check_file "{}"'

echo "Scan complete."

#!/bin/bash

# --- Script Validation ---
# We need at least 2 arguments: a file path and one timestamp to cut at.
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 \"/path/to/video.mp4\" \"cut_time_1\" \"cut_time_2\" ..."
    echo "Example (for one cut): $0 \"my_video.mp4\" \"00:12:15\""
    exit 1
fi

# The first argument is the file path.
file="$1"

# Check if the file exists.
if [ ! -f "$file" ]; then
    echo "Error: File not found at '$1'"
    exit 1
fi

# Use 'shift' to remove the file path from the argument list.
shift

# All remaining arguments are the user-provided cut points.
user_timestamps=("$@")

# --- Auto-detect Timestamps ---
echo "Analyzing video duration..."

# Get video duration using ffprobe.
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file")
if [ -z "$duration" ]; then
    echo "Error: Could not determine video duration."
    exit 1
fi

# Build the final list of timestamps for splitting.
# It starts with 0, includes all user cut points, and ends with the total duration.
timestamps=("00:00:00" "${user_timestamps[@]}" "$duration")

# --- Splitting Logic ---
num_scenes=$(( ${#timestamps[@]} - 1 ))

echo "Processing file: $file ($duration seconds)"
echo "Creating $num_scenes scenes based on ${#user_timestamps[@]} cut point(s)."

for (( i=0; i<$num_scenes; i++ )); do
  start="${timestamps[$i]}"
  end="${timestamps[$((i+1))]}"
  
  output_filename=$(printf "scene_%02d.mp4" $((i+1)))

  echo "  -> Creating Scene $((i+1)): from $start to $end"
  
  ffmpeg -hide_banner -i "$file" -ss "$start" -to "$end" -c copy "$output_filename" -y
done

echo "✅ All scenes have been split!"

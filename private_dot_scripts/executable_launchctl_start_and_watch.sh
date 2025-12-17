#!/bin/bash

# Script to start a launchctl service and watch its logs
# Usage: ./launchctl_start_and_watch.sh <service_name>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <service_name>"
    echo "Example: $0 com.m1.zip_update_force"
    exit 1
fi

SERVICE_NAME="$1"

echo "Starting launchctl service: $SERVICE_NAME"
launchctl start "$SERVICE_NAME"

if [ $? -eq 0 ]; then
    echo "Service started successfully. Watching logs..."
    echo "Press Ctrl+C to stop watching logs"
    echo "----------------------------------------"
    
    # Watch logs for the service
    log stream --predicate "process == \"$SERVICE_NAME\"" --style syslog
else
    echo "Failed to start service: $SERVICE_NAME"
    exit 1
fi

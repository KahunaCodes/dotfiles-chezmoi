#!/bin/bash
# pmset-server-standard.sh
# Standardized power settings for always-on Mac servers
# Target machines: main-mac, automation-mac, homebridge-mac
#
# Run with: sudo ./pmset-server-standard.sh

set -e

HOSTNAME=$(scutil --get ComputerName)
echo "Configuring power management for: $HOSTNAME"

# Verify we're on a server machine, not away-mac
if [[ "$HOSTNAME" == *"away"* ]] || [[ "$HOSTNAME" == *"Away"* ]]; then
    echo "ERROR: This script is for server machines only, not portables."
    echo "Use pmset-portable.sh for away-mac."
    exit 1
fi

echo "Applying server power settings..."

# Disable sleep entirely at system level
sudo pmset -a sleep 0
sudo pmset -a disksleep 0
sudo pmset -a standby 0

# Display sleep - 0 for headless, 10 for main-mac with display
if [[ "$HOSTNAME" == *"main"* ]] || [[ "$HOSTNAME" == *"Main"* ]]; then
    sudo pmset -a displaysleep 10
    echo "  - Display sleep: 10 min (has active display)"
else
    sudo pmset -a displaysleep 0
    echo "  - Display sleep: disabled (headless)"
fi

# Keep SSH/remote sessions alive
sudo pmset -a ttyskeepawake 1

# Wake on LAN for remote access
sudo pmset -a womp 1

# TCP keepalive for persistent connections
sudo pmset -a tcpkeepalive 1

# Power Nap for background tasks (updates, Time Machine, etc)
sudo pmset -a powernap 1

# Auto restart after power failure - CRITICAL for servers
sudo pmset -a autorestart 1

# Power button sleeps instead of shutdown (already default, skip to avoid syntax issues)
# sudo pmset -a sleepbeforepowerbutton 1

# Low power mode off - we want full performance
sudo pmset -a lowpowermode 0

echo ""
echo "Settings applied. Current config:"
pmset -g

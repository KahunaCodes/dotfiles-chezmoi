#!/bin/bash
# pmset-portable-away-mac.sh
# Optimized power settings for M3 MacBook Pro (away-mac)
# Balances battery life with usability
#
# Run with: sudo ./pmset-portable-away-mac.sh

set -e

HOSTNAME=$(scutil --get ComputerName)
echo "Configuring power management for: $HOSTNAME (M3 MacBook Pro)"

#=============================================================================
# BATTERY POWER SETTINGS (-b)
# Priority: Maximum battery life
#=============================================================================
echo ""
echo "=== Battery Power Settings ==="

# Display sleep after 2 minutes on battery (was 0 - never)
sudo pmset -b displaysleep 2
echo "  - Display sleep: 2 min"

# System sleep after 5 minutes on battery (was 1 min - too aggressive)
sudo pmset -b sleep 5
echo "  - System sleep: 5 min"

# Disk sleep after 5 minutes
sudo pmset -b disksleep 5
echo "  - Disk sleep: 5 min"

# Standby enabled - hibernates after prolonged sleep for battery savings
sudo pmset -b standby 1
echo "  - Standby: enabled"

# Hibernate mode 3 = RAM + disk image (fast wake, safe sleep)
# Mode 25 = full hibernation (slower wake, better battery)
sudo pmset -b hibernatemode 3
echo "  - Hibernate mode: 3 (safe sleep)"

# Power Nap OFF on battery - saves battery
sudo pmset -b powernap 0
echo "  - Power Nap: disabled"

# Wake on LAN enabled even on battery for remote access
sudo pmset -b womp 1
echo "  - Wake on LAN: enabled"

# Dim display slightly on battery
sudo pmset -b lessbright 1
echo "  - Reduce brightness: enabled"

# Keep TCP connections alive (for SSH, etc)
sudo pmset -b tcpkeepalive 1
echo "  - TCP keepalive: enabled"

# Keep TTY sessions alive
sudo pmset -b ttyskeepawake 1
echo "  - TTY keepawake: enabled"

# Low power mode - consider enabling for max battery
sudo pmset -b lowpowermode 0
echo "  - Low power mode: disabled (enable with -b lowpowermode 1 for max battery)"

#=============================================================================
# AC POWER SETTINGS (-c)
# Priority: Performance and availability
#=============================================================================
echo ""
echo "=== AC Power Settings ==="

# Display sleep after 15 minutes when plugged in (was 0 - never)
sudo pmset -c displaysleep 15
echo "  - Display sleep: 15 min"

# System sleep after 30 minutes when plugged in (was 1 min)
sudo pmset -c sleep 30
echo "  - System sleep: 30 min"

# Disk sleep disabled when on power
sudo pmset -c disksleep 0
echo "  - Disk sleep: disabled"

# Standby enabled but with longer delay
sudo pmset -c standby 1
echo "  - Standby: enabled"

# Power Nap ON when plugged in - background updates while sleeping
sudo pmset -c powernap 1
echo "  - Power Nap: enabled"

# Wake on LAN enabled on AC
sudo pmset -c womp 1
echo "  - Wake on LAN: enabled"

# TCP keepalive
sudo pmset -c tcpkeepalive 1
echo "  - TCP keepalive: enabled"

# TTY keepawake
sudo pmset -c ttyskeepawake 1
echo "  - TTY keepawake: enabled"

# Hibernate mode 3
sudo pmset -c hibernatemode 3
echo "  - Hibernate mode: 3 (safe sleep)"

# Low power mode off on AC
sudo pmset -c lowpowermode 0
echo "  - Low power mode: disabled"

echo ""
echo "Settings applied. Current config:"
pmset -g custom

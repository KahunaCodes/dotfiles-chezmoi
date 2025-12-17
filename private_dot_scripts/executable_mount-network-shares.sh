#!/bin/bash
# mount-network-shares.sh - Auto-mounts SMB shares
# 
# CONFIG FILES:
#   ~/.smb_creds      - Credentials (MAIN_MAC_USER, MAIN_MAC_PASS, AWAY_MAC_USER, AWAY_MAC_PASS)
#   This script       - Add/remove shares in the MOUNT SHARES section below
#
# USAGE:
#   ~/scripts/mount-network-shares.sh
#   Or via alias: hb-mount (from any machine)

LOG_FILE="$HOME/scripts/mount-shares.log"
CREDS_FILE="$HOME/.smb_creds"
MAX_LOG_LINES=500

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    local lines=$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)
    if [ "$lines" -gt $MAX_LOG_LINES ]; then
        tail -n $MAX_LOG_LINES "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
    fi
}

# Source credentials
if [ ! -f "$CREDS_FILE" ]; then
    log "ERROR: Credentials file not found: $CREDS_FILE"
    exit 1
fi
source "$CREDS_FILE"

cleanup_stale_mount() {
    local SHARE_NAME="$1"
    local MOUNT_POINT="/Volumes/$SHARE_NAME"
    
    # Check if mount point exists but is not actually mounted
    if [ -d "$MOUNT_POINT" ] && ! mount | grep -q " on $MOUNT_POINT "; then
        log "Cleaning stale mount point: $MOUNT_POINT"
        rmdir "$MOUNT_POINT" 2>/dev/null || rm -rf "$MOUNT_POINT" 2>/dev/null
    fi
    
    # Also clean any -1, -2 variants that might exist
    for suffix in "-1" "-2" "-3"; do
        local VARIANT="${MOUNT_POINT}${suffix}"
        if [ -d "$VARIANT" ]; then
            # If it's mounted, unmount it first
            if mount | grep -q " on $VARIANT "; then
                log "Unmounting variant: $VARIANT"
                umount "$VARIANT" 2>/dev/null
                sleep 1
            fi
            log "Removing variant mount point: $VARIANT"
            rmdir "$VARIANT" 2>/dev/null || rm -rf "$VARIANT" 2>/dev/null
        fi
    done
}

mount_share() {
    local SERVER_IP="$1"
    local SHARE_NAME="$2"
    local USER="$3"
    local PASS="$4"
    local MOUNT_POINT="/Volumes/$SHARE_NAME"
    
    # Skip if already correctly mounted
    if mount | grep -q "@${SERVER_IP}/${SHARE_NAME} on $MOUNT_POINT "; then
        return 0
    fi
    
    # Clean up any stale or variant mount points first
    cleanup_stale_mount "$SHARE_NAME"
    
    # URL encode password
    local ENCODED_PASS=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PASS', safe=''))")
    
    log "Mounting $SHARE_NAME"
    
    # Use osascript - creates mount points automatically like Finder
    osascript -e "mount volume \"smb://${USER}:${ENCODED_PASS}@${SERVER_IP}/${SHARE_NAME}\"" 2>> "$LOG_FILE"
    
    sleep 1
    
    # Verify mount is at correct path (not -1 variant)
    if mount | grep -q "@${SERVER_IP}/${SHARE_NAME} on $MOUNT_POINT "; then
        log "SUCCESS: $SHARE_NAME at $MOUNT_POINT"
        return 0
    elif mount | grep -q "@${SERVER_IP}/${SHARE_NAME} "; then
        # Mounted but at wrong path - find where and fix
        local ACTUAL_PATH=$(mount | grep "@${SERVER_IP}/${SHARE_NAME} " | awk '{print $3}')
        log "WARNING: $SHARE_NAME mounted at $ACTUAL_PATH instead of $MOUNT_POINT"
        # Unmount and retry after cleanup
        umount "$ACTUAL_PATH" 2>/dev/null
        cleanup_stale_mount "$SHARE_NAME"
        sleep 1
        osascript -e "mount volume \"smb://${USER}:${ENCODED_PASS}@${SERVER_IP}/${SHARE_NAME}\"" 2>> "$LOG_FILE"
        sleep 1
        if mount | grep -q "@${SERVER_IP}/${SHARE_NAME} on $MOUNT_POINT "; then
            log "SUCCESS (retry): $SHARE_NAME at $MOUNT_POINT"
            return 0
        else
            log "FAILED: Could not mount $SHARE_NAME at correct path"
            return 1
        fi
    else
        log "FAILED: $SHARE_NAME"
        return 1
    fi
}

# ============================================
# MOUNT SHARES - Edit this section as needed
# Format: mount_share "server_ip" "share_name" "user_var" "pass_var"
# ============================================

# Main-mac shares (192.168.1.3)
mount_share "192.168.1.3" "vault-new" "$MAIN_MAC_USER" "$MAIN_MAC_PASS"
mount_share "192.168.1.3" "vault-redundant" "$MAIN_MAC_USER" "$MAIN_MAC_PASS"
mount_share "192.168.1.3" "mac-ex-storage" "$MAIN_MAC_USER" "$MAIN_MAC_PASS"

# Away-mac share (LAN first, Tailscale fallback)
if ping -c 1 -W 2 192.168.1.5 > /dev/null 2>&1; then
    AWAY_IP="192.168.1.5"
else
    AWAY_IP="100.74.75.41"
    log "away-mac: using Tailscale"
fi
mount_share "$AWAY_IP" "away-mac-network-drive" "$AWAY_MAC_USER" "$AWAY_MAC_PASS"

log "Mount check complete"

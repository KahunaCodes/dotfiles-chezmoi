#!/bin/bash

# Network Priority Manager for macOS
# Keeps Wi-Fi enabled but disconnects from networks when Ethernet is active

# Function to check if Ethernet is connected
check_ethernet_status() {
    # Check all Ethernet interfaces (en0, en1, etc.) for active connection
    for interface in $(networksetup -listallhardwareports | grep -A 1 "Ethernet\|Thunderbolt" | grep "Device:" | awk '{print $2}'); do
        if [[ $(ifconfig "$interface" 2>/dev/null | grep "status: active") ]]; then
            return 0  # Ethernet is connected
        fi
    done
    return 1  # No Ethernet connection
}

# Function to get current Wi-Fi interface (usually en0 or en1)
get_wifi_interface() {
    networksetup -listallhardwareports | grep -A 1 "Wi-Fi" | grep "Device:" | awk '{print $2}'
}

# Function to disconnect from Wi-Fi without turning it off
disconnect_wifi() {
    local wifi_interface=$(get_wifi_interface)
    if [[ -n "$wifi_interface" ]]; then
        # Get current network
        current_network=$(networksetup -getairportnetwork "$wifi_interface" 2>/dev/null | grep "Current Wi-Fi Network:" | cut -d: -f2 | xargs)
        
        if [[ -n "$current_network" && "$current_network" != "You are not associated with an AirPort network." ]]; then
            echo "$(date): Ethernet detected - disconnecting from Wi-Fi network: $current_network"
            sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -z
            
            # Optional: Remove auto-join temporarily (uncomment if needed)
            # networksetup -setairportnetwork "$wifi_interface" "" 2>/dev/null
        fi
    fi
}

# Function to check if should reconnect to Wi-Fi
should_reconnect_wifi() {
    local wifi_interface=$(get_wifi_interface)
    if [[ -n "$wifi_interface" ]]; then
        current_network=$(networksetup -getairportnetwork "$wifi_interface" 2>/dev/null | grep "Current Wi-Fi Network:" | cut -d: -f2 | xargs)
        
        if [[ -z "$current_network" || "$current_network" == "You are not associated with an AirPort network." ]]; then
            return 0  # Should reconnect
        fi
    fi
    return 1  # Already connected or shouldn't reconnect
}

# Main monitoring loop
main() {
    echo "$(date): Network Priority Manager started"
    
    # Store previous state
    previous_ethernet_state=""
    
    while true; do
        if check_ethernet_status; then
            # Ethernet is connected
            if [[ "$previous_ethernet_state" != "connected" ]]; then
                echo "$(date): Ethernet connection detected"
                disconnect_wifi
                previous_ethernet_state="connected"
            fi
            # Keep disconnecting if macOS tries to auto-reconnect
            disconnect_wifi 2>/dev/null
        else
            # Ethernet is not connected
            if [[ "$previous_ethernet_state" != "disconnected" ]]; then
                echo "$(date): Ethernet disconnected - Wi-Fi can now connect"
                previous_ethernet_state="disconnected"
                
                # Optional: Auto-connect to preferred network (uncomment and modify if needed)
                # wifi_interface=$(get_wifi_interface)
                # networksetup -setairportnetwork "$wifi_interface" "YourNetworkName" "YourPassword"
            fi
        fi
        
        # Wait 2 seconds before checking again
        sleep 2
    done
}

# Run main function
main

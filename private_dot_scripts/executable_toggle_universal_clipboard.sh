#!/bin/bash

PLIST=~/Library/Preferences/ByHost/com.apple.coreservices.useractivityd.plist

# Read current state (assume true if missing)
CURRENT=$(defaults read "$PLIST" ActivityReceivingAllowed 2>/dev/null)

if [[ "$CURRENT" == "1" ]]; then
  echo "🔴 Disabling Universal Clipboard..."
  defaults write "$PLIST" ActivityAdvertisingAllowed -bool false
  defaults write "$PLIST" ActivityReceivingAllowed -bool false
  killall useractivityd
  echo "✅ Universal Clipboard is now OFF"
else
  echo "🟢 Enabling Universal Clipboard..."
  defaults write "$PLIST" ActivityAdvertisingAllowed -bool true
  defaults write "$PLIST" ActivityReceivingAllowed -bool true
  killall useractivityd
  echo "✅ Universal Clipboard is now ON"
fi

# Server Setup Reference

Configuration for headless Mac servers that cannot be managed by Chezmoi directly (requires sudo/root).

## NOPASSWD Sudo

Allows automation users to run sudo without password prompt.

### Setup Commands

**automation-mac (user: m1):**
```bash
echo 'm1 ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/nopasswd-m1
sudo chmod 440 /etc/sudoers.d/nopasswd-m1
```

**hb-mac (user: homebridge):**
```bash
echo 'homebridge ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/nopasswd-homebridge
sudo chmod 440 /etc/sudoers.d/nopasswd-homebridge
```

### Verify
```bash
ssh automation-mac 'sudo whoami'  # Should output: root
ssh hb-mac 'sudo whoami'          # Should output: root
```

---

## PATH for Homebrew (Non-Interactive SSH)

Interactive shells load ~/.zshrc, but non-interactive SSH doesn't. Fix:

```bash
echo '/opt/homebrew/bin
/opt/homebrew/sbin' | sudo tee /etc/paths.d/homebrew
```

### Status
- automation-mac: ✅ Done
- hb-mac: ✅ Done
- away-mac: ❌ Needs setup
- main-mac: ❌ Needs setup

---

## SSH Hardening

Key-only authentication (disable password):

```bash
sudo sed -i.bak 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo launchctl kickstart -k system/com.openssh.sshd
```

### Verify
```bash
grep '^PasswordAuthentication' /etc/ssh/sshd_config
# Should output: PasswordAuthentication no
```

### Status
All 4 machines: ✅ Hardened

---

## Power Management (pmset)

Headless server settings:

```bash
sudo pmset -a sleep 0 displaysleep 0 disksleep 0 womp 1 autorestart 1
```

| Setting | Value | Purpose |
|---------|-------|---------|
| sleep | 0 | Never sleep |
| displaysleep | 0 | Display stays on |
| disksleep | 0 | Disks stay spinning |
| womp | 1 | Wake on LAN |
| autorestart | 1 | Restart after power loss |

---

## Sleep Prevention (Lid Closed)

### Option 1: Amphetamine + Enhancer
- Install Amphetamine (App Store)
- Install Amphetamine Enhancer (companion app)
- Enable Closed-Display Mode
- UNCHECK "Allow system sleep when display is closed"

### Option 2: caffeinate LaunchDaemon
```bash
cat << 'PLIST' | sudo tee /Library/LaunchDaemons/com.prevent-sleep.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.prevent-sleep</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/caffeinate</string>
        <string>-s</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
PLIST
sudo launchctl load /Library/LaunchDaemons/com.prevent-sleep.plist
```

---

## Headless Machine Checklist

- [ ] SSH key-only (PasswordAuthentication no)
- [ ] NOPASSWD sudo for automation user
- [ ] /etc/paths.d/homebrew for PATH
- [ ] pmset configured (sleep 0, womp 1, autorestart 1)
- [ ] Sleep prevention (Amphetamine or caffeinate)
- [ ] Screen Sharing enabled
- [ ] Remote Login enabled

---

*Last updated: December 18, 2025*

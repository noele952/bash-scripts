#!/bin/bash

# === CONFIGURATION ===

LOGFILE="$HOME/system_update.log"
EMAIL="your.email@example.com"  # Set your email or leave empty to disable email notifications

echo "=== System Update started at $(date) ===" | tee -a "$LOGFILE"

# Update package lists
echo "Updating package lists..." | tee -a "$LOGFILE"
sudo apt update >> "$LOGFILE" 2>&1

# Upgrade packages
echo "Upgrading packages..." | tee -a "$LOGFILE"
sudo apt upgrade -y >> "$LOGFILE" 2>&1

# Full upgrade (optional, uncomment if you want dist-upgrade)
# sudo apt full-upgrade -y >> "$LOGFILE" 2>&1

# Clean up unused packages
echo "Removing unnecessary packages..." | tee -a "$LOGFILE"
sudo apt autoremove -y >> "$LOGFILE" 2>&1

# Check if reboot is required
REBOOT_REQUIRED=false
if [ -f /var/run/reboot-required ]; then
  echo "Reboot is required." | tee -a "$LOGFILE"
  REBOOT_REQUIRED=true
else
  echo "No reboot required." | tee -a "$LOGFILE"
fi

echo "=== System Update finished at $(date) ===" | tee -a "$LOGFILE"

# Send email notification if EMAIL is set
if [ -n "$EMAIL" ]; then
  SUBJECT="System Update Report on $(hostname)"
  BODY=$(cat "$LOGFILE")
  echo "$BODY" | mail -s "$SUBJECT" "$EMAIL"
fi

# Optionally reboot if needed
if $REBOOT_REQUIRED; then
  echo "System will reboot in 1 minute to apply updates."
  sudo shutdown -r +1 "System rebooting to apply updates"
fi

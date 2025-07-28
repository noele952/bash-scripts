#!/bin/bash

# === CONFIGURATION ===

LOGFILE="$HOME/security_scan.log"
EMAIL="your.email@example.com"  # Change to your email address

# Ensure required tools are installed
for tool in chkrootkit rkhunter; do
  if ! command -v $tool &> /dev/null; then
    echo "❌ $tool is not installed. Please install it before running this script."
    exit 1
  fi
done

echo "=== Security scan started at $(date) ===" >> "$LOGFILE"

# Update rkhunter database
echo "Updating rkhunter database..." | tee -a "$LOGFILE"
sudo rkhunter --update >> "$LOGFILE" 2>&1

# Run chkrootkit
echo "Running chkrootkit..." | tee -a "$LOGFILE"
sudo chkrootkit >> "$LOGFILE" 2>&1

# Run rkhunter check
echo "Running rkhunter..." | tee -a "$LOGFILE"
sudo rkhunter --check --sk >> "$LOGFILE" 2>&1

# Check for warnings or infections in log
WARNINGS=$(grep -Ei "Warning|Infected|Found" "$LOGFILE")

if [ -n "$WARNINGS" ]; then
  echo "🚨 Potential security issues found!" | tee -a "$LOGFILE"
  SUBJECT="Security Scan Alert on $(hostname)"
  cat "$LOGFILE" | mail -s "$SUBJECT" "$EMAIL"
else
  echo "✅ No issues found during security scan." | tee -a "$LOGFILE"
fi

echo "=== Security scan finished at $(date) ===" >> "$LOGFILE"

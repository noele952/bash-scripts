#!/bin/bash

LOGFILE="$HOME/system_health.log"

# Timestamp
echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOGFILE"

# CPU usage
echo "CPU Load:" >> "$LOGFILE"
top -bn1 | grep "Cpu(s)" | \
  awk '{printf "  CPU Usage: %.1f%%\n", 100 - $8}' >> "$LOGFILE"

# Memory usage
echo "Memory Usage:" >> "$LOGFILE"
free -h | awk '/^Mem/ { printf "  Used: %s / %s\n", $3, $2 }' >> "$LOGFILE"

# Disk usage
echo "Disk Usage (Root '/'): " >> "$LOGFILE"
df -h / | awk 'NR==2 { printf "  Used: %s / %s (%s)\n", $3, $2, $5 }' >> "$LOGFILE"

echo "" >> "$LOGFILE"

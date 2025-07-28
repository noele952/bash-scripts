#!/bin/bash

# Location to log the output
LOGFILE="$HOME/disk_usage.log"

# Directory to analyze in detail (customize if needed)
TARGET_DIR="/home"

# Add timestamp
echo "=== Disk Usage Report @ $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOGFILE"

# Overall disk usage summary
echo ">> df -h output:" >> "$LOGFILE"
df -h >> "$LOGFILE"

echo "" >> "$LOGFILE"

# Detailed usage of target directory (top 10 largest directories)
echo ">> Top 10 disk usage in $TARGET_DIR:" >> "$LOGFILE"
du -h --max-depth=1 "$TARGET_DIR" 2>/dev/null | sort -hr | head -n 10 >> "$LOGFILE"

echo -e "\n" >> "$LOGFILE"

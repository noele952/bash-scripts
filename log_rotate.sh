#!/bin/bash

# === CONFIGURATION ===

LOGFILE="/var/log/myapp.log"       # Path to the log file you want to rotate
BACKUP_DIR="/var/log/myapp_backups"  # Where to store compressed logs
MAX_BACKUPS=5                      # Number of rotated logs to keep

# === PREP ===

mkdir -p "$BACKUP_DIR"

if [ ! -f "$LOGFILE" ]; then
  echo "❌ Log file not found: $LOGFILE"
  exit 1
fi

# === ROTATE ===

TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
ARCHIVE_FILE="$BACKUP_DIR/$(basename "$LOGFILE")_$TIMESTAMP.gz"

# Move current log and compress it
cp "$LOGFILE" "$LOGFILE.rotating"    # Keep writing to original log
cat "$LOGFILE.rotating" | gzip > "$ARCHIVE_FILE"
rm "$LOGFILE.rotating"

# Clear original log file
: > "$LOGFILE"

echo "✅ Rotated and compressed: $ARCHIVE_FILE"

# === CLEANUP OLD BACKUPS ===

# List gz files sorted by modification time, delete older ones
cd "$BACKUP_DIR" || exit 1
COUNT=$(ls -1t *.gz 2>/dev/null | wc -l)

if [ "$COUNT" -gt "$MAX_BACKUPS" ]; then
  DELETE_COUNT=$((COUNT - MAX_BACKUPS))
  echo "🧹 Deleting $DELETE_COUNT old backups..."

  ls -1t *.gz | tail -n "$DELETE_COUNT" | xargs rm -f
fi

#!/bin/bash

# === CONFIGURATION ===

# Folders to back up (add as many as needed)
FOLDERS=(
  "/home/yourusername/Documents"
  "/home/yourusername/Pictures"
  "/home/yourusername/Projects"
)

# Where to store backups (e.g., external drive or NAS)
DEST="/mnt/backup_drive/compressed_backups"

# Log file
LOGFILE="$HOME/backup.log"

# Archive filename with timestamp
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="backup_$TIMESTAMP.tar.gz"
ARCHIVE_PATH="$DEST/$ARCHIVE_NAME"

# Create destination directory if needed
mkdir -p "$DEST"

# === START BACKUP ===
echo "=== Backup started at $TIMESTAMP ===" >> "$LOGFILE"

# Create a temporary staging folder
STAGING_DIR=$(mktemp -d)

# Copy each folder into the staging area
for folder in "${FOLDERS[@]}"; do
  if [ -d "$folder" ]; then
    echo "Adding $folder to backup..." >> "$LOGFILE"
    cp -a "$folder" "$STAGING_DIR" >> "$LOGFILE" 2>&1
  else
    echo "⚠️ Warning: $folder not found. Skipping." >> "$LOGFILE"
  fi
done

# Create the compressed archive
tar -czf "$ARCHIVE_PATH" -C "$STAGING_DIR" . >> "$LOGFILE" 2>&1

# Clean up staging folder
rm -rf "$STAGING_DIR"

# Check result
if [ $? -eq 0 ]; then
  echo "✅ Backup completed successfully. Archive: $ARCHIVE_PATH" >> "$LOGFILE"
else
  echo "❌ Backup failed during compression or file copy." >> "$LOGFILE"
fi

echo "" >> "$LOGFILE"

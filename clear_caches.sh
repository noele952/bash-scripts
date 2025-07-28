#!/bin/bash

# === CONFIGURATION ===
DRY_RUN=false

# === Parse arguments ===
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "🔍 Dry run enabled — no files will be deleted."
fi

# === Function to delete or simulate deletion ===
delete() {
  if $DRY_RUN; then
    echo "Would delete: $*"
  else
    rm -rf "$@"
  fi
}

# === Begin Cleanup ===
echo "🧹 Starting cache cleanup at $(date)"

# === Clean /tmp ===
echo "Cleaning /tmp..."
delete /tmp/* /tmp/.* 2>/dev/null

# === Clean user cache ===
echo "Cleaning ~/.cache for user: $USER"
delete "$HOME/.cache"/*

# === Clean Firefox cache ===
FIREFOX_CACHE="$HOME/.mozilla/firefox"
if [ -d "$FIREFOX_CACHE" ]; then
  echo "Cleaning Firefox cache..."
  find "$FIREFOX_CACHE" -type d -name "cache2" | while read -r dir; do
    delete "$dir"
  done
fi

# === Clean Chrome/Chromium cache ===
CHROME_CACHE="$HOME/.cache/google-chrome"
CHROMIUM_CACHE="$HOME/.cache/chromium"

if [ -d "$CHROME_CACHE" ]; then
  echo "Cleaning Chrome cache..."
  delete "$CHROME_CACHE"/*
fi

if [ -d "$CHROMIUM_CACHE" ]; then
  echo "Cleaning Chromium cache..."
  delete "$CHROMIUM_CACHE"/*
fi

# === Clean APT package cache ===
if command -v apt > /dev/null; then
  echo "Cleaning APT package cache..."
  if $DRY_RUN; then
    echo "Would run: apt clean"
  else
    apt clean -y
  fi
fi

# === Optional: DNF/YUM support ===
# if command -v dnf > /dev/null; then
#   echo "Cleaning DNF cache..."
#   if $DRY_RUN; then
#     echo "Would run: dnf clean all"
#   else
#     dnf clean all -y
#   fi
# fi

# if command -v yum > /dev/null; then
#   echo "Cleaning YUM cache..."
#   if $DRY_RUN; then
#     echo "Would run: yum clean all"
#   else
#     yum clean all -y
#   fi
# fi

echo "✅ Cleanup ${DRY_RUN:+(dry run )}complete!"

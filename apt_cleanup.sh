#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root."
  exit 1
fi

echo "🧹 Starting APT cleanup at $(date)"

# Update package list
echo "Updating package lists..."
apt update -y

# Remove unused packages
echo "Removing unused packages..."
apt autoremove -y

# Clean local repository of retrieved package files
echo "Cleaning package cache..."
apt clean

echo "✅ APT cleanup complete!"

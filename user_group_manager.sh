#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root."
  exit 1
fi

while true; do
  echo ""
  echo "===== User & Group Management Menu ====="
  echo "1. Create a new user"
  echo "2. Delete a user"
  echo "3. Create a new group"
  echo "4. Delete a group"
  echo "5. Exit"
  echo "========================================"
  read -rp "Choose an option [1-5]: " choice

  case "$choice" in
    1)
      read -rp "Enter the new username: " username
      read -rp "Enter full name (optional): " fullname
      read -s -rp "Enter password for $username: " password
      echo
      useradd -m -c "$fullname" "$username"
      echo "$username:$password" | chpasswd
      echo "✅ User '$username' created successfully."
      ;;
    2)
      read -rp "Enter the username to delete: " username
      read -rp "Delete home directory too? [y/N]: " delete_home
      if [[ "$delete_home" =~ ^[Yy]$ ]]; then
        userdel -r "$username"
      else
        userdel "$username"
      fi
      echo "✅ User '$username' deleted."
      ;;
    3)
      read -rp "Enter the group name to create: " groupname
      groupadd "$groupname"
      echo "✅ Group '$groupname' created successfully."
      ;;
    4)
      read -rp "Enter the group name to delete: " groupname
      groupdel "$groupname"
      echo "✅ Group '$groupname' deleted."
      ;;
    5)
      echo "👋 Exiting script. Goodbye!"
      break
      ;;
    *)
      echo "❌ Invalid option. Please choose 1-5."
      ;;
  esac
done

Absolutely! Here's the **enhanced version** of your `user_group_manager.sh` script with:

---

### ✅ **Improvements:**

1. **Username and group name format validation**
2. **Check if the user or group already exists before creating/deleting**

---

### 📜 **Updated Script: `user_group_manager.sh`**

```bash
#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root."
  exit 1
fi

# Validate username or group name (letters, digits, underscores, 1-32 chars)
validate_name() {
  [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_-]{0,31}$ ]]
}

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

      if ! validate_name "$username"; then
        echo "❌ Invalid username. Must start with a letter or underscore and be up to 32 characters."
        continue
      fi

      if id "$username" &>/dev/null; then
        echo "❌ User '$username' already exists."
        continue
      fi

      read -rp "Enter full name (optional): " fullname
      read -s -rp "Enter password for $username: " password
      echo
      useradd -m -c "$fullname" "$username"
      echo "$username:$password" | chpasswd
      echo "✅ User '$username' created successfully."
      ;;
    2)
      read -rp "Enter the username to delete: " username

      if ! id "$username" &>/dev/null; then
        echo "❌ User '$username' does not exist."
        continue
      fi

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

      if ! validate_name "$groupname"; then
        echo "❌ Invalid group name. Must start with a letter or underscore and be up to 32 characters."
        continue
      fi

      if getent group "$groupname" > /dev/null; then
        echo "❌ Group '$groupname' already exists."
        continue
      fi

      groupadd "$groupname"
      echo "✅ Group '$groupname' created successfully."
      ;;
    4)
      read -rp "Enter the group name to delete: " groupname

      if ! getent group "$groupname" > /dev/null; then
        echo "❌ Group '$groupname' does not exist."
        continue
      fi

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
```

---

### 🔧 How to Use

Same steps as before:

1. Save the script: `nano user_group_manager.sh`
2. Make it executable: `chmod +x user_group_manager.sh`
3. Run it: `sudo ./user_group_manager.sh`

---

Would you like the script to **log actions to a file** or **email admin on changes** next?

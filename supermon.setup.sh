#!/bin/bash

# Supermon Setup Script
# 6/7/2024 By WROG208 \ N4ASS
# www.lonewolfsystem.org

SUPERMON_DIR="/srv/http/supermon"
CONFIG_FILE="${SUPERMON_DIR}/global.inc"
ALLMON_CONFIG_FILE="${SUPERMON_DIR}/allmon.ini"
ASTERISK_MANAGER_CONF="/etc/asterisk/manager.conf"
STATUS_PAGES_FILE="/usr/local/sbin/status_pages.txt"
DATETIME=$(date +"%Y%m%d_%H%M%S")

# Backup function
backup_file() {
  local file=$1
  local backup_file="${file}.${DATETIME}.bak"
  if [ -f "$file" ]; then
    sudo cp "$file" "$backup_file"
    echo "Backup of $file created at $backup_file"
  else
    echo "File $file does not exist, skipping backup."
  fi
}

# Function to configure Supermon
configure_supermon() {
  dialog --title "Supermon Setup" --msgbox "Configuring Supermon..." 7 40
  
  CALL=$(dialog --inputbox "Enter CALL SIGN:" 8 40 3>&1 1>&2 2>&3 3>&1)
  NAME=$(dialog --inputbox "Enter NAME (optional):" 8 40 3>&1 1>&2 2>&3 3>&1)
  LOCATION=$(dialog --inputbox "Enter LOCATION (optional):" 8 40 3>&1 1>&2 2>&3 3>&1)
  TITLE2=$(dialog --inputbox "Enter TITLE2 (optional):" 8 40 3>&1 1>&2 2>&3 3>&1)
  TITLE3=$(dialog --inputbox "Enter TITLE3 (optional):" 8 40 3>&1 1>&2 2>&3 3>&1)
  LOCALZIP=$(dialog --inputbox "Enter LOCALZIP (optional):" 8 40 3>&1 1>&2 2>&3 3>&1)
  USERNAME=$(dialog --inputbox "Create NEW Username:" 8 40 3>&1 1>&2 2>&3 3>&1)
  PASSWORD=$(dialog --inputbox "Create NEW Password For Supermon:" 8 40 3>&1 1>&2 2>&3 3>&1)
  PASSWORD_CONFIRM=$(dialog --inputbox "Confirm NEW Password For Supermon:" 8 40 3>&1 1>&2 2>&3 3>&1)
  NODE_NUMBER=$(dialog --inputbox "Enter Node Number:" 8 40 3>&1 1>&2 2>&3 3>&1)
  PORT=$(dialog --inputbox "Enter Asterisk Manager Port (default 5038):" 8 40 "5038" 3>&1 1>&2 2>&3 3>&1)

  # Check for required inputs and password confirmation
  if [ -z "$CALL" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$PASSWORD_CONFIRM" ] || [ -z "$NODE_NUMBER" ] || [ -z "$PORT" ]; then
    dialog --msgbox "Error: All required fields must be filled in." 7 40
    exit 1
  fi

  if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
    dialog --msgbox "Error: Passwords do not match." 7 40
    exit 1
  fi

  # Backup configuration files
  backup_file "$CONFIG_FILE"
  backup_file "$ALLMON_CONFIG_FILE"
  backup_file "$ASTERISK_MANAGER_CONF"

  # Update global.inc file
  sudo sed -i "s/\$CALL = \".*\";/\$CALL = \"$CALL\";/g" "$CONFIG_FILE"
  sudo sed -i "s/\$NAME = \".*\";/\$NAME = \"$NAME\";/g" "$CONFIG_FILE"
  sudo sed -i "s/\$LOCATION = \".*\";/\$LOCATION = \"$LOCATION\";/g" "$CONFIG_FILE"
  sudo sed -i "s/\$TITLE2 = \".*\";/\$TITLE2 = \"$TITLE2\";/g" "$CONFIG_FILE"
  sudo sed -i "s/\$TITLE3 = \".*\";/\$TITLE3 = \"$TITLE3\";/g" "$CONFIG_FILE"
  sudo sed -i "s/\$LOCALZIP = \".*\";/\$LOCALZIP = \"$LOCALZIP\";/g" "$CONFIG_FILE"

  # Change to Supermon directory
  cd "$SUPERMON_DIR"

  # Create the .htpasswd file for authentication
  echo -e "${PASSWORD}\n${PASSWORD}" | sudo htpasswd -cB .htpasswd "$USERNAME"

  if [ $? -ne 0 ]; then
    dialog --msgbox "Error: Failed to create .htpasswd file." 7 40
    exit 1
  fi

  # Configure Apache to use .htpasswd for authentication
  sudo bash -c "cat > /etc/httpd/conf/extra/supermon.conf <<EOL
Alias /supermon ${SUPERMON_DIR}
<Directory ${SUPERMON_DIR}>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    AuthType Basic
    AuthName \"Restricted Content\"
    AuthUserFile ${SUPERMON_DIR}/.htpasswd
    Require valid-user
</Directory>
EOL"
  
  # Ensure httpd.conf includes the supermon.conf
  if ! grep -q "Include conf/extra/supermon.conf" /etc/httpd/conf/httpd.conf; then
    sudo bash -c "echo 'Include conf/extra/supermon.conf' >> /etc/httpd/conf/httpd.conf"
  fi

  # Update the Asterisk manager.conf file with the new password
  sudo sed -i "s/^secret *= *.*/secret = $PASSWORD/" "$ASTERISK_MANAGER_CONF"

  # Update the allmon.ini file with the node information
  sudo bash -c "cat > $ALLMON_CONFIG_FILE <<EOL
[$NODE_NUMBER]
host=127.0.0.1:$PORT
user=admin
passwd=$PASSWORD
menu=yes
hideNodeURL=no

[All Nodes]
nodes=$NODE_NUMBER
menu=yes

[lsNodes]
url="/cgi-bin/lsnodes_web?node=$NODE_NUMBER"
menu=yes
EOL"

  dialog --yesno "Would you like to add status pages for other GMRS systems, equipment vendors, or system group websites?" 7 40
  if [ $? -eq 0 ]; then
    if [ -f "$STATUS_PAGES_FILE" ]; then
      sudo cat "$STATUS_PAGES_FILE" >> "$ALLMON_CONFIG_FILE"
    else
      dialog --msgbox "Status pages file $STATUS_PAGES_FILE not found." 7 40
    fi
  fi

  # Restart Apache and Asterisk to apply changes
  sudo systemctl restart httpd
  sudo systemctl restart asterisk

  dialog --msgbox "Supermon configured." 7 40
}

# Function to add users to Supermon
add_user_to_supermon() {
  dialog --title "Add User to Supermon" --msgbox "Adding user to Supermon..." 7 40
  
  USERNAME=$(dialog --inputbox "Enter NEW Username:" 8 40 3>&1 1>&2 2>&3 3>&1)
  PASSWORD=$(dialog --inputbox "Create NEW Password For Supermon:" 8 40 3>&1 1>&2 2>&3 3>&1)
  PASSWORD_CONFIRM=$(dialog --inputbox "Confirm NEW Password For Supermon:" 8 40 3>&1 1>&2 2>&3 3>&1)

  # Check for empty inputs and password confirmation
  if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$PASSWORD_CONFIRM" ]; then
    dialog --msgbox "Error: Username, Password, and Password Confirmation are required fields." 7 40
    exit 1
  fi

  if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
    dialog --msgbox "Error: Passwords do not match." 7 40
    exit 1
  fi
  
  cd "$SUPERMON_DIR"
  
  # Add a new user to the existing .htpasswd file
  echo -e "${PASSWORD}\n${PASSWORD}" | sudo htpasswd -B .htpasswd "$USERNAME"

  if [ $? -ne 0 ]; then
    dialog --msgbox "Error: Failed to add user to .htpasswd file." 7 40
    exit 1
  fi
  
  dialog --msgbox "User added to Supermon." 7 40
}

# Function to revert changes
revert_changes() {
  if [ -f "${CONFIG_FILE}.${DATETIME}.bak" ]; then
    sudo mv "${CONFIG_FILE}.${DATETIME}.bak" "$CONFIG_FILE"
  fi
  if [ -f "${ALLMON_CONFIG_FILE}.${DATETIME}.bak" ]; then
    sudo mv "${ALLMON_CONFIG_FILE}.${DATETIME}.bak" "$ALLMON_CONFIG_FILE"
  fi
  if [ -f "${ASTERISK_MANAGER_CONF}.${DATETIME}.bak" ]; then
    sudo mv "${ASTERISK_MANAGER_CONF}.${DATETIME}.bak" "$ASTERISK_MANAGER_CONF"
  fi
  dialog --msgbox "Changes reverted." 7 40

  # Restart Apache and Asterisk to apply changes
  sudo systemctl restart httpd
  sudo systemctl restart asterisk
}

# Main menu
show_menu() {
  CHOICE=$(dialog --clear --title "Supermon Setup Menu\nwww.lonewolfsystem.org" \
           --menu "Choose an option:" \
           20 60 10 \
           1 "First-time Supermon Setup" \
           2 "Add User to Supermon" \
           3 "Revert changes" \
           4 "Exit" \
           3>&1 1>&2 2>&3)
  case $CHOICE in
    1)
      configure_supermon
      ;;
    2)
      add_user_to_supermon
      ;;
    3)
      revert_changes
      ;;
    4)
      exit 0
      ;;
    *)
      dialog --msgbox "Invalid option. Please choose again." 7 40
      ;;
  esac
}

# Main loop
while true; do
  show_menu
done

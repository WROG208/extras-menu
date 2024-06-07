#!/bin/bash

# Variables
FILE="/srv/http/supermon/global.inc"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${FILE}.${DATE}.bak"

# Function to modify specific fields
modify_file() {
  read -p "Enter CALL SIGN: " CALL
  read -p "Enter NAME: " NAME
  read -p "Enter LOCATION: " LOCATION
  read -p "Enter TITLE2 (NOT OBLIGATORY): " TITLE2
  read -p "Enter TITLE3 (NOT OBLIGATORY): " TITLE3
  read -p "Enter LOCALZIP (TO GET LOCAL WEATHER): " LOCALZIP

  # Create a backup with timestamp
  cp "$FILE" "$BACKUP_FILE"
  if [ $? -eq 0 ]; then
    echo "Backup created successfully at $BACKUP_FILE."
  else
    echo "Failed to create backup."
    exit 1
  fi

  # Modify specific lines
  sed -i "s/\$CALL = \".*\";/\$CALL = \"$CALL\";/g" "$FILE"
  sed -i "s/\$NAME = \".*\";/\$NAME = \"$NAME\";/g" "$FILE"
  sed -i "s/\$LOCATION = \".*\";/\$LOCATION = \"$LOCATION\";/g" "$FILE"
  sed -i "s/\$TITLE2 = \".*\";/\$TITLE2 = \"$TITLE2\";/g" "$FILE"
  sed -i "s/\$TITLE3 = \".*\";/\$TITLE3 = \"$TITLE3\";/g" "$FILE"
  sed -i "s/\$LOCALZIP = \".*\";/\$LOCALZIP = \"$LOCALZIP\";/g" "$FILE"
  
  if [ $? -eq 0 ]; then
    echo "File modified successfully."
  else
    echo "Failed to modify the file."
    exit 1
  fi
}

# Function to revert changes
revert_changes() {
  echo "Available backups:"
  ls "${FILE}".*.bak
  read -p "Enter the backup file to revert to: " CHOSEN_BACKUP

  if [ -f "$CHOSEN_BACKUP" ]; then
    cp "$CHOSEN_BACKUP" "$FILE"
    if [ $? -eq 0 ]; then
      echo "Changes reverted to the selected backup file."
    else
      echo "Failed to revert changes."
      exit 1
    fi
  else
    echo "Backup file not found. Cannot revert changes."
  fi
}

# Menu function
show_menu() {
  echo "1) Modify file"
  echo "2) Revert changes"
  echo "3) Exit"
}

# Main loop
while true; do
  show_menu
  read -p "Choose an option: " choice
  case $choice in
    1)
      modify_file
      ;;
    2)
      revert_changes
      ;;
    3)
      exit 0
      ;;
    *)
      echo "Invalid option. Please choose again."
      ;;
  esac
done

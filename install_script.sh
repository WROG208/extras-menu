#!/bin/bash

# 5/26/2024 By WROG208 \ N4ASS
# www.lonewolfsystem.org


SCRIPTS=("menu.sh" "gsmbi.py" "cronJ.sh")
DESTINATION="/usr/local/sbin"


REPO_DIR=$(basename $(pwd))

move_and_make_executable() {
  local script=$1
  if [ ! -f "$script" ]; then
    echo "Error: $script not found in the current directory."
    exit 1
  fi

  sudo mv "$script" "$DESTINATION"
  # Make the script executable
  sudo chmod +x "$DESTINATION/$script"
}


for script in "${SCRIPTS[@]}"; do
  move_and_make_executable "$script"
done


for script in "${SCRIPTS[@]}"; do
  if [ -f "$DESTINATION/$script" ] && [ -x "$DESTINATION/$script" ]; then
    echo "$script has been installed to $DESTINATION and made executable."
  else
    echo "Error: Installation failed for $script."
    exit 1
  fi
done

cd ..
rm -rf "$REPO_DIR"

echo "Installation and cleanup completed successfully."

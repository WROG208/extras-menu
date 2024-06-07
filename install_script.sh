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

  sudo chmod +x "$DESTINATION/$script"
}

install_pip() {
  if ! command -v pip &> /dev/null; then
    echo "pip is not installed. Installing pip..."
    wget https://bootstrap.pypa.io/pip/3.5/get-pip.py -O get-pip.py
    sudo python3 get-pip.py
    rm get-pip.py
    if ! command -v pip &> /dev/null; then
      echo "Error: Failed to install pip. Please install it manually."
      exit 1
    fi
  else
    echo "pip is already installed."
  fi
}

install_gtts() {
  if ! python3 -c "import gtts" &> /dev/null; then
    echo "gTTS is not installed. Installing now..."
    sudo pip install gtts
    if [ $? -ne 0 ]; then
      echo "Error: Failed to install gTTS. Please install it manually."
      exit 1
    fi
  else
    echo "gTTS is already installed."
  fi
}


install_pip


install_gtts


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

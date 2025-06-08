#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Function to create a unique backup directory name with month, day, hours, and minutes
get_backup_dirname() {
  local timestamp
  timestamp=$(date +"%m%d_%H%M")
  echo "back-up_${timestamp}"
}

DIRS="Kvantum qt5ct qt6ct zsh nvim kitty fastfetch starship"
STOW_DIR="$HOME/dotfiles"

run_stow() {
  for DIR_NAME in $DIRS; do
    echo -e "\n🔧 Processing ${DIR_NAME}..."

    # Find all files in the stow source directory
    TARGET_FILES=$(find "$STOW_DIR/$DIR_NAME" -type f)

    for FILE in $TARGET_FILES; do
      # Remove $STOW_DIR/$DIR_NAME/ prefix to get the relative path
      REL_PATH="${FILE#"$STOW_DIR/$DIR_NAME/"}"
      DEST="$HOME/$REL_PATH"

      # If destination exists and is not a symlink, back it up
      if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
        BACKUP_SUFFIX=$(get_backup_dirname)
        BACKUP_PATH="$DEST.backup-$BACKUP_SUFFIX"
        echo "📦 Backing up $DEST → $BACKUP_PATH"
        mkdir -p "$(dirname "$BACKUP_PATH")"
        mv "$DEST" "$BACKUP_PATH"
      fi
    done

    # Now safely stow
    echo "📁 Stowing $DIR_NAME..."
    stow "$DIR_NAME"

    if [ $? -eq 0 ]; then
      echo "✅ $DIR_NAME stowed successfully!"
    else
      echo "❌ Failed to stow $DIR_NAME."
      exit 1
    fi
  done
}

# Check if stow installed
if ! command -v stow &> /dev/null
then
  echo "Stow not installed! Installing Stow..."
  if ! sudo pacman -S stow --noconfirm; then
    echo "Failed to install Stow. Exiting."
    exit 1
  fi
fi

# Check if dotfiles exists
printf "${NOTE} Cloning and Installing ${SKY_BLUE}Dotfiles${RESET}....\n"

if [ -d dotfiles ]; then
  cd dotfiles
  git stash && git pull
  run_stow
else
  if git clone --depth=1 https://github.com/disintegrating8/dotfiles; then
    cd dotfiles || exit 1
    run_stow
  else
    echo -e "$ERROR Failed to download ${YELLOW}dotfiles${RESET}"
  fi
fi

printf "\n%.0s" {1..2}

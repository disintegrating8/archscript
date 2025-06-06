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
else
  if git clone --depth=1 https://github.com/disintegrating8/dotfiles; then
    cd dotfiles || exit 1
  else
    echo -e "$ERROR Failed to download ${YELLOW}dotfiles${RESET}"
  fi
fi

printf "\n%.0s" {1..2}

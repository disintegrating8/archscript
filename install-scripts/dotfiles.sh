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

# Check if Hyprland-Dots exists
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

old_dotfiles(){
    printf "${NOTE} Cloning and Installing ${SKY_BLUE}dotfiles${RESET}....\n"
    REPO_URL="https://github.com/disintegrating8/dotfiles.git"
    REPO_DIR="$HOME/dotfiles"

    if ! command -v stow &> /dev/null
    then
      echo "Stow not installed! Installing Stow..."
      if ! sudo pacman -S stow --noconfirm; then
        echo "Failed to install Stow. Exiting."
        exit 1
      fi
    fi

    cd ~

    # Check if git is installed
    if ! command -v git &> /dev/null
    then
        echo "${INFO} Git not found! ${SKY_BLUE}Installing Git...${RESET}"
        if ! sudo pacman -S git --noconfirm; then
            echo "Failed to install Git. Exiting."
            exit 1
        fi
    fi

    if [ -d "$REPO_DIR" ]; then
        echo "${YELLOW}$REPO_DIR exists. Updating the repository... ${RESET}"
        cd "$REPO_DIR"
        git stash && git pull
    else
        echo "${MAGENTA}$Distro_DIR does not exist. Cloning the repository...${RESET}"
        git clone --depth=1 "$REPO_URL" "$REPO_DIR"
        cd "$REPO_DIR"
    fi


    # Check if the repository already exists
    if [ -d "$REPO_NAME" ]; then
      echo "Repository '$REPO_NAME' already exists. Skipping clone"
    else
      git clone --depth=1 "$REPO_URL"
    fi

    # Check if the clone was successful
    if [ $? -eq 0 ]; then
      cd "$REPO_DIR"
      #stow --adopt bash
      #stow --adopt starship
      #stow --adopt kitty
      #stow --adopt nvim
    else
      echo "Failed to clone the repository."
      exit 1
    fi
}



#!/bin/bash

REPO_URL="https://github.com/disintegrating8/archscript.git"
REPO_DIR="$HOME/archscript"

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
  git clone "$REPO_URL"
fi

# Check if the clone was successful
if [ $? -eq 0 ]; then
  cd "$REPO_DIR"
  stow --adopt bash
  stow --adopt starship
  stow --adopt kitty
  stow --adopt nvim
else
  echo "Failed to clone the repository."
  exit 1
fi

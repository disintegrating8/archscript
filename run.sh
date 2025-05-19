#!/bin/bash

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
CYAN='\033[36m'
GREEN='\033[32m'
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

# Variables
REPO_URL="https://github.com/disintegrating8/archscript.git"
REPO_DIR="$HOME/archscript"

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

printf "%b\n" "${YELLOW}--------------------------${RC}" 
printf "%b\n" "${YELLOW}What do you want to do? ${RC}" 
printf "%b\n" "${YELLOW}1. BSPWM Setup ${RC}" 
printf "%b\n" "${YELLOW}2. Gnome Tiling Setup ${RC}" 
printf "%b\n" "${YELLOW}3. Install Applications ${RC}" 
printf "%b" "${YELLOW}Please select one: ${RC}"
read -r choice
case "$choice" in
    1)
        chmod +x bspwm-setup.sh
        ./bspwm-setup.sh
        ;;
    2)
        chmod +x gnome-setup.sh
        ./gnome-setup.sh
        ;;
    3)
        chmod +x install.sh
        ./install.sh
        ;;       
    *)
        printf "%b\n" "${RED}Invalid selection! Please choose 1, 2, or 3.${RC}"
        return 1
        ;;
esac

#!/bin/bash

. ./common-script.sh
. ./common-service-script.sh

# Variables
REPO_URL="https://github.com/disintegrating8/archscript.git"
REPO_DIR="$HOME/archscript"

setupRepo() {
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
}

options() {
    printf "%b\n" "${YELLOW}--------------------------${RC}" 
    printf "%b\n" "${YELLOW}What do you want to do? ${RC}" 
    printf "%b\n" "${YELLOW}1. BSPWM Setup ${RC}" 
    printf "%b\n" "${YELLOW}2. Gnome Desktop Setup ${RC}" 
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
}

setupRepo
Options

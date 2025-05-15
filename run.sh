#!/bin/bash

. ../common-script.sh
. ../common-service-script.sh

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

    if [ -d "$Distro_DIR" ]; then
        echo "${YELLOW}$Distro_DIR exists. Updating the repository... ${RESET}"
        cd "$Distro_DIR"
        git stash && git pull
        chmod +x install.sh
        ./install.sh
    else
        echo "${MAGENTA}$Distro_DIR does not exist. Cloning the repository...${RESET}"
        git clone --depth=1 "$Github_URL" "$Distro_DIR"
        cd "$Distro_DIR"
        chmod +x install.sh
        ./install.sh
    fi
}

Options() {
    printf "%b\n" "${YELLOW}--------------------------${RC}" 
    printf "%b\n" "${YELLOW}What do you want to do? ${RC}" 
    printf "%b\n" "${YELLOW}1. Arch-Server Setup ${RC}" 
    printf "%b\n" "${YELLOW}2. Gnome Desktop Setup ${RC}" 
    printf "%b\n" "${YELLOW}3. BSPWM Setup ${RC}" 
    printf "%b\n" "${YELLOW}4. Install Applications ${RC}" 
    printf "%b" "${YELLOW}Please select one: ${RC}"
    read -r choice
    case "$choice" in
        1)
            chmod +x futurefile.sh
            ;;
        2)
            chmod +x alsofuturefile.sh
            ;;
        3)
            chmod +x bspwm-setup.sh
            ./bspwm-setup.sh
            
        4)
            printf "%b\n" "${GREEN}No display manager will be installed${RC}"
            chmod +x application-setup.sh
            ./application-setup.sh
            ;;
        *)
            printf "%b\n" "${RED}Invalid selection! Please choose 1, 2, 3, or 4.${RC}"
            return 1
            ;;
    esac
}

setupRepo
Options

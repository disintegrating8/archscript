#!/bin/bash

print_logo() {
    cat << "EOF"

    ██████╗ ███████╗██████╗ ██╗    ██╗███╗   ███╗    ██████╗ ████████╗██╗    ██╗
    ██╔══██╗██╔════╝██╔══██╗██║    ██║████╗ ████║    ██╔══██╗╚══██╔══╝██║    ██║
    ██████╔╝███████╗██████╔╝██║ █╗ ██║██╔████╔██║    ██████╔╝   ██║   ██║ █╗ ██║
    ██╔══██╗╚════██║██╔═══╝ ██║███╗██║██║╚██╔╝██║    ██╔══██╗   ██║   ██║███╗██║
    ██████╔╝███████║██║     ╚███╔███╔╝██║ ╚═╝ ██║    ██████╔╝   ██║   ╚███╔███╔╝  Arch Linux
    ╚═════╝ ╚══════╝╚═╝      ╚══╝╚══╝ ╚═╝     ╚═╝    ╚═════╝    ╚═╝    ╚══╝╚══╝   2025

EOF
}

clear
print_logo

. ./common-script.sh
. ./global-function.sh

script_directory=install-scripts

# Function to execute a script if it exists and make it executable
execute_script() {
    local script="$1"
    local script_path="$script_directory/$script"
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        if [ -x "$script_path" ]; then
            env "$script_path"
        else
            echo "Failed to make script '$script' executable."
        fi
    else
        echo "Script '$script' not found in '$script_directory'."
    fi
}

# Check if NVIDIA GPU is detected
if lspci | grep -i "nvidia" &> /dev/null; then
    read -rp "Jensen Huang's MoneyMaking SHIT Detected. Install Nvidia Drivers? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Installing..."
        execute_script "nvidia.sh"
    else
        echo "Skipped driver installation."
    fi

printf "%b\n" "${YELLOW}--------------------------${RC}" 
printf "%b\n" "${YELLOW}Pick WM ${RC}" 
printf "%b\n" "${YELLOW}1. DWM ${RC}" 
printf "%b\n" "${YELLOW}2. BSPWM ${RC}" 
printf "%b\n" "${YELLOW}3. i3 - does not work btw ${RC}"
printf "%b" "${YELLOW}Please select one: ${RC}"
read -r choice
case "$choice" in
    1)
        WM="dwm"
        ;;
    2)
        WM="bspwm"
        ;;
    3)
        WM="i3"
        ;;
    *)
        printf "%b\n" "${RED}Invalid selection! Please choose 1, 2, or 3.${RC}"
        return 1
        ;;
esac
echo "You selected $WM"
LOG="Install-Logs/$WM-Install-Scripts-$(date +%d-%H%M%S).log"
echo "${INFO} Installing ${SKY_BLUE}Additional packages neccessary...${RESET}"
execute_script "$WM.sh"

# Running scripts that apply to all WM
echo "${INFO} Configuring ${SKY_BLUE}pacman...${RESET}"
execute_script "pacman.sh"

echo "${INFO} Configuring ${SKY_BLUE}pipewire...${RESET}"
execute_script "pipewire.sh"

echo "${INFO} Installing ${SKY_BLUE}necessary fonts...${RESET}"
execute_script "fonts.sh"

echo "${INFO} Installing ${SKY_BLUE}disintegrating8/dotfiles...${RESET}"
execute_script "dotfiles.sh"

echo "${INFO} Adding user into ${SKY_BLUE}input group...${RESET}" | tee -a "$LOG"
execute_script "InputGroup.sh"

read -p "Install GTK and QT themes? (y/n): " theme
if [[ $theme =~ ^[Yy]$ ]]; then
    echo "${INFO} Installing ${SKY_BLUE}GTK and QT themes...${RESET}" | tee -a "$LOG"
    execute_script "app_themes.sh"
fi

read -p "Do you want script to configure Bluetooth? (y/n): " blue
if [[ $blue =~ ^[Yy]$ ]]; then
    execute_script "bluetooth.sh"
fi

read -p "Do you want Thunar file manager to be installed? (y/n)" file
if [[ $file =~ ^[Yy]$ ]]; then
    execute_script "thunar.sh"
    read -p "Do you want Thunar to be the default file manager? (y/n)" d_file
    if [[$d_file = ~ ^[Yy]$ ]]; then
        execute_script "thunar_default.sh"
    fi
fi

read -p "Install zsh shell with Oh-My-Zsh? (y/n)" zsh
if [[ $zsh =~ ^[Yy]$ ]]; then
    execute_script "bluetooth.sh"
fi


read -p "Are you installing on Asus ROG laptops? (y/n)" rog
if [[ $rog =~ ^[Yy]$ ]]; then
    execute_script "rog.sh"
fi

read -p "${NOTE} Do you want to configure cjk input? (y/n): " choice
if [[ $choice =~ ^[Yy]$ ]]; then
    execute_script "cjk-input.sh"
fi

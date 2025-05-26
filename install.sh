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


# Run
echo "${INFO} Installing ${SKY_BLUE}Additional packages neccessary...${RESET}"
install_packages "${FONTS[@]}"

echo "${INFO} Configuring ${SKY_BLUE}pipewire...${RESET}"
install_packages "${FONTS[@]}"

echo "${INFO} Installing ${SKY_BLUE}necessary fonts...${RESET}"
install_packages "${FONTS[@]}"

echo "${INFO} Installing ${SKY_BLUE}BSPWM Dotfiles..."
install_packages "${FONTS[@]}"


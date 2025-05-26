#!/bin/sh

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/01-DWM-Install-Scripts-$(date +%d-%H%M%S).log"

setupDWM() {
    printf "%b\n" "${YELLOW}Installing DWM Dependencies...${RC}"
    sudo pacman -S --needed --noconfirm base-devel libx11 libxinerama libxft imlib2 git unzip flameshot lxappearance-gtk3 feh polkit-gnome xclip picom dunst
}

makeDWM() {
    cd "$HOME" && git clone https://github.com/ChrisTitusTech/dwm-titus.git # CD to Home directory to install dwm-titus
    # This path can be changed (e.g. to linux-toolbox directory)
    cd dwm-titus/ # Hardcoded path, maybe not the best.
    "$ESCALATION_TOOL" make clean install # Run make clean install
}

install_slstatus() {
    printf "Do you want to install slstatus? (y/N): "
    read -r response
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        printf "%b\n" "${YELLOW}Installing slstatus${RC}"
        cd "$HOME/dwm-titus/slstatus" || { 
            printf "%b\n" "${RED}Failed to change directory to slstatus${RC}"
            return 1
        }
        if "$ESCALATION_TOOL" make clean install; then
            printf "%b\n" "${GREEN}slstatus installed successfully${RC}"
        else
            printf "%b\n" "${RED}Failed to install slstatus${RC}"
            return 1
        fi
    else
        printf "%b\n" "${GREEN}Skipping slstatus installation${RC}"
    fi
    cd "$HOME"
}

checkEnv
setupDisplayManager
setupDWM
makeDWM
install_slstatus
install_font
clone_config_folders
configure_backgrounds

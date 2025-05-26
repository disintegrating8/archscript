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


# Check if PulseAudio package is installed
if pacman -Qq | grep -qw '^pulseaudio$'; then
    echo "$ERROR PulseAudio is detected as installed. Uninstall it first or edit install.sh on line 211 (execute_script 'pipewire.sh')." | tee -a "$LOG"
    printf "\n%.0s" {1..2} 
    exit 1
fi

# Check if NVIDIA GPU is detected
if lspci | grep -i "nvidia" &> /dev/null; then
    echo "Jensen Huang's MoneyMaking SHIT Detected. Installing Nvidia Drivers..."
    # Detect LTS kernel (running or installed)
    if uname -r | grep -q "lts" || pacman -Q linux-lts &>/dev/null; then
        DRIVER="nvidia-lts"
    else
        DRIVER="nvidia-dkms"
    fi
    read -rp "Install $DRIVER driver? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Installing $DRIVER..."
        yay -S --needed "$DRIVER"
    else
        echo "Skipped $DRIVER installation."
    fi
    read -rp "Install libva-nvidia-driver? [y/N]: " confirm
    if [["$confirm" =~ ^[Yy]$ ]]; then
        echo "Installing VAAPI drivers for NVIDIA..."
        yay -S --needed libva-nvidia-driver
fi

# Add 'input_group' option if necessary
if [ "$input_group_detected" == "true" ]; then
    options_command+=(
        "input_group" "Add your USER to input group for some polybar functionality?" "OFF"
    )
fi

# Run
echo "${INFO} Installing ${SKY_BLUE}Additional packages neccessary...${RESET}"
install_packages "${FONTS[@]}"

echo "${INFO} Configuring ${SKY_BLUE}pipewire...${RESET}"
install_packages "${FONTS[@]}"

echo "${INFO} Installing ${SKY_BLUE}necessary fonts...${RESET}"
install_packages "${FONTS[@]}"

echo "${INFO} Installing ${SKY_BLUE}BSPWM Dotfiles..."
install_packages "${FONTS[@]}"

# copy fastfetch config if arch.png is not present
if [ ! -f "$HOME/.config/fastfetch/arch.png" ]; then
    cp -r assets/fastfetch "$HOME/.config/"
fi

clear

# final check essential packages if it is installed
execute_script "02-Final-Check.sh"

printf "\n%.0s" {1..1}

# Check if hyprland or hyprland-git is installed
if pacman -Q hyprland &> /dev/null || pacman -Q hyprland-git &> /dev/null; then
    printf "\n ${OK} 👌 Hyprland is installed. However, some essential packages may not be installed. Please see above!"
    printf "\n${CAT} Ignore this message if it states ${YELLOW}All essential packages${RESET} are installed as per above\n"
    sleep 2
    printf "\n%.0s" {1..2}

    printf "\n${NOTE} You can start Hyprland by typing ${SKY_BLUE}Hyprland${RESET} (IF SDDM is not installed) (note the capital H!).\n"
    printf "\n${NOTE} However, it is ${YELLOW}highly recommended to reboot${RESET} your system.\n\n"

    while true; do
        echo -n "${CAT} Would you like to reboot now? (y/n): "
        read HYP
        HYP=$(echo "$HYP" | tr '[:upper:]' '[:lower:]')

        if [[ "$HYP" == "y" || "$HYP" == "yes" ]]; then
            echo "${INFO} Rebooting now..."
            systemctl reboot 
            break
        elif [[ "$HYP" == "n" || "$HYP" == "no" ]]; then
            echo "👌 ${OK} You chose NOT to reboot"
            printf "\n%.0s" {1..1}
            # Check if NVIDIA GPU is present
            if lspci | grep -i "nvidia" &> /dev/null; then
                echo "${INFO} HOWEVER ${YELLOW}NVIDIA GPU${RESET} detected. Reminder that you must REBOOT your SYSTEM..."
                printf "\n%.0s" {1..1}
            fi
            break
        else
            echo "${WARN} Invalid response. Please answer with 'y' or 'n'."
        fi
    done
else
    # Print error message if neither package is installed
    printf "\n${WARN} Hyprland is NOT installed. Please check 00_CHECK-time_installed.log and other files in the Install-Logs/ directory..."
    printf "\n%.0s" {1..3}
    exit 1
fi


printf "\n%.0s" {1..2}

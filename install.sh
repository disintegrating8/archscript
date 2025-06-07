#!/bin/bash

clear

# Set some colors for output messages
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

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/WM-Install-Scripts-$(date +%d-%H%M%S).log"

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "${ERROR}  This script should ${WARNING}NOT${RESET} be executed as root!! Exiting......." | tee -a "$LOG"
    printf "\n%.0s" {1..2} 
    exit 1
fi

# Check if PulseAudio package is installed
if pacman -Qq | grep -qw '^pulseaudio$'; then
    echo "$ERROR PulseAudio is detected as installed. Uninstall it first or edit install.sh on line 211 (execute_script 'pipewire.sh')." | tee -a "$LOG"
    printf "\n%.0s" {1..2} 
    exit 1
fi

# Check if base-devel is installed
if pacman -Q base-devel &> /dev/null; then
    echo "base-devel is already installed."
else
    echo "$NOTE Install base-devel.........."

    if sudo pacman -S --noconfirm base-devel; then
        echo "👌 ${OK} base-devel has been installed successfully." | tee -a "$LOG"
    else
        echo "❌ $ERROR base-devel not found nor cannot be installed."  | tee -a "$LOG"
        echo "$ACTION Please install base-devel manually before running this script... Exiting" | tee -a "$LOG"
        exit 1
    fi
fi

# install whiptails if detected not installed. Necessary for this version
if ! command -v whiptail >/dev/null; then
    echo "${NOTE} - whiptail is not installed. Installing..." | tee -a "$LOG"
    sudo pacman -S --noconfirm libnewt
    printf "\n%.0s" {1..1}
fi

clear

printf "\n%.0s" {1..2}  
echo -e "\e[35m
██╗  ██╗ ██████╗ ██████╗  ██████╗     ██╗    ██╗███╗   ███╗███████╗
╚██╗██╔╝██╔═══██╗██╔══██╗██╔════╝     ██║    ██║████╗ ████║██╔════╝
 ╚███╔╝ ██║   ██║██████╔╝██║  ███╗    ██║ █╗ ██║██╔████╔██║███████╗
 ██╔██╗ ██║   ██║██╔══██╗██║   ██║    ██║███╗██║██║╚██╔╝██║╚════██║
██╔╝ ██╗╚██████╔╝██║  ██║╚██████╔╝    ╚███╔███╔╝██║ ╚═╝ ██║███████║ 2025
╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝      ╚══╝╚══╝ ╚═╝     ╚═╝╚══════╝ Arch Linux
\e[0m"
printf "\n%.0s" {1..1} 

# Welcome message using whiptail (for displaying information)
whiptail --title "XORG WMs (2025) Install Script" \
    --msgbox "Welcome XORG WM (2025) Install Script!!!\n\n\
ATTENTION: Run a full system update and Reboot first !!! (Highly Recommended)\n\n\
NOTE: If you are installing on a VM, ensure to enable 3D acceleration!" \
    15 80

# Ask if the user wants to proceed
if ! whiptail --title "Proceed with Installation?" \
    --yesno "Would you like to proceed?" 7 50; then
    echo -e "\n"
    echo "❌ ${INFO} You 🫵 chose ${YELLOW}NOT${RESET} to proceed. ${YELLOW}Exiting...${RESET}" | tee -a "$LOG"
    echo -e "\n" 
    exit 1
fi

echo "👌 ${OK} ${RESET} ${SKY_BLUE}lets continue with the installation...${RESET}" | tee -a "$LOG"

sleep 1
printf "\n%.0s" {1..1}

# install pciutils if detected not installed. Necessary for detecting GPU
if ! pacman -Qs pciutils > /dev/null; then
    echo "${NOTE} - pciutils is not installed. Installing..." | tee -a "$LOG"
    sudo pacman -S --noconfirm pciutils
    printf "\n%.0s" {1..1}
fi

# Path to the install-scripts directory
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

# Check if yay or paru is installed
echo "${INFO} - Checking if yay or paru is installed"
if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
    echo "${CAT} - Neither yay nor paru found. Asking 🗣️ USER to select..."
    while true; do
        aur_helper=$(whiptail --title "Neither Yay nor Paru is installed" --checklist "Neither Yay nor Paru is installed. Choose one AUR.\n\nNOTE: Select only 1 AUR helper!\nINFO: spacebar to select" 12 60 2 \
            "yay" "AUR Helper yay" "OFF" \
            "paru" "AUR Helper paru" "OFF" \
            3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then  
            echo "❌ ${INFO} You cancelled the selection. ${YELLOW}Goodbye!${RESET}" | tee -a "$LOG"
            exit 0 
        fi

        if [ -z "$aur_helper" ]; then
            whiptail --title "Error" --msgbox "You must select at least one AUR helper to proceed." 10 60 2
            continue 
        fi

        echo "${INFO} - You selected: $aur_helper as your AUR helper"  | tee -a "$LOG"

        aur_helper=$(echo "$aur_helper" | tr -d '"')

        # Check if multiple helpers were selected
        if [[ $(echo "$aur_helper" | wc -w) -ne 1 ]]; then
            whiptail --title "Error" --msgbox "You must select exactly one AUR helper." 10 60 2
            continue  
        else
            break 
        fi
    done
else
    echo "${NOTE} - AUR helper is already installed. Skipping AUR helper selection."
fi

# List of services to check for active login managers
services=("gdm.service" "gdm3.service" "lightdm.service" "lxdm.service" "sddm.service")

# Function to check if any login services are active
check_services_running() {
    active_services=()  # Array to store active services
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            active_services+=("$svc")  
        fi
    done

    if [ ${#active_services[@]} -gt 0 ]; then
        return 0  
    else
        return 1  
    fi
}

if check_services_running; then
    active_list=$(printf "%s\n" "${active_services[@]}")

    # Display the active login manager(s) in the whiptail message box
    whiptail --title "Active non-ly login manager(s) detected" \
        --msgbox "The following login manager(s) are active:\n\n$active_list\n\nIf you want to replace with ly, stop and disable the active services above, reboot before running this script\n\nYour option to install ly has now been removed" 23 80
fi

# Check if NVIDIA GPU is detected
nvidia_detected=false
if lspci | grep -i "nvidia" &> /dev/null; then
    nvidia_detected=true
    whiptail --title "NVIDIA GPU Detected" --msgbox "NVIDIA GPU detected in your system.\n\nNOTE: The script will install nvidia-dkms, nvidia-utils, and nvidia-settings if you chose to configure." 12 60
fi

# Initialize the options array for whiptail checklist
options_command=(
    whiptail --title "Select Options" --checklist "Choose options to install or configure\nNOTE: 'SPACEBAR' to select & 'TAB' key to change selection" 28 85 20
)

# Add NVIDIA options if detected
if [ "$nvidia_detected" == "true" ]; then
    options_command+=(
        "nvidia" "Do you want script to configure NVIDIA GPU?" "OFF"
        "nouveau" "Do you want Nouveau to be blacklisted?" "OFF"
    )
fi

# Conditionally add SDDM and SDDM theme options if no active login manager is found
if ! check_services_running; then
    options_command+=(
        "ly" "Install & configure ly login manager?" "OFF"
    )
fi

options_command+=(
    "app_themes" "Install GTK and QT themes?" "OFF"
    "input_group" "Add your USER to input group?" "OFF"
    "fcitx" "Install & configure fcitx5 input method for cjk inputs?" "OFF"
    "bluetooth" "Do you want script to configure Bluetooth?" "OFF"
    "thunar" "Do you want Thunar file manager to be installed?" "OFF"
    "zsh" "Install zsh shell with starship?" "OFF"
    "personal" "Install personal packages and flatpak?" "OFF"
)

# Capture the selected options before the while loop starts
while true; do
    selected_options=$("${options_command[@]}" 3>&1 1>&2 2>&3)

    # Check if the user pressed Cancel (exit status 1)
    if [ $? -ne 0 ]; then
        echo -e "\n"
        echo "❌ ${INFO} You 🫵 cancelled the selection. ${YELLOW}Goodbye!${RESET}" | tee -a "$LOG"
        exit 0  # Exit the script if Cancel is pressed
    fi

    # If no option was selected, notify and restart the selection
    if [ -z "$selected_options" ]; then
        whiptail --title "Warning" --msgbox "No options were selected. Please select at least one option." 10 60
        continue  # Return to selection if no options selected
    fi

    # Strip the quotes and trim spaces if necessary (sanitize the input)
    selected_options=$(echo "$selected_options" | tr -d '"' | tr -s ' ')

    # Convert selected options into an array (preserving spaces in values)
    IFS=' ' read -r -a options <<< "$selected_options"

    # Prepare the confirmation message
    confirm_message="You have selected the following options:\n\n"
    for option in "${options[@]}"; do
        confirm_message+=" - $option\n"
    done
    confirm_message+="\nAre you happy with these choices?"

    # Confirmation prompt
    if ! whiptail --title "Confirm Your Choices" --yesno "$(printf "%s" "$confirm_message")" 25 80; then
        echo -e "\n"
        echo "❌ ${SKY_BLUE}You're not 🫵 happy${RESET}. ${YELLOW}Returning to options...${RESET}" | tee -a "$LOG"
        continue 
    fi

    echo "👌 ${OK} You confirmed your choices. Proceeding with ${SKY_BLUE}Installation...${RESET}" | tee -a "$LOG"
    break  
done

printf "\n%.0s" {1..1}

# Ensuring base-devel is installed
execute_script "base.sh"
sleep 1
execute_script "pacman.sh"
sleep1

if [ "$aur_helper" == "paru" ]; then
    execute_script "paru.sh"
elif [ "$aur_helper" == "yay" ]; then
    execute_script "yay.sh"
fi

sleep 1

echo "${INFO} Installing ${SKY_BLUE}disintegrating8/dotfiles...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "dotfiles.sh"

echo "${INFO} Installing ${SKY_BLUE}dwm packages...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "dwm.sh"

echo "${INFO} Configuring ${SKY_BLUE}pipewire...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "pipewire.sh"

echo "${INFO} Installing ${SKY_BLUE}necessary fonts...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "fonts.sh"

# Clean up the selected options (remove quotes and trim spaces)
selected_options=$(echo "$selected_options" | tr -d '"' | tr -s ' ')

# Convert selected options into an array (splitting by spaces)
IFS=' ' read -r -a options <<< "$selected_options"

# Loop through selected options
for option in "${options[@]}"; do
    case "$option" in
        ly)
            if check_services_running; then
                active_list=$(printf "%s\n" "${active_services[@]}")
                whiptail --title "Error" --msgbox "One of the following login services is running:\n$active_list\n\nPlease stop & disable it or DO not choose ly." 12 60
                exec "$0"  
            else
                echo "${INFO} Installing and configuring ${SKY_BLUE}ly...${RESET}" | tee -a "$LOG"
                execute_script "ly.sh"
            fi
            ;;
        nvidia)
            echo "${INFO} Configuring ${SKY_BLUE}nvidia stuff${RESET}" | tee -a "$LOG"
            execute_script "nvidia.sh"
            ;;
        nouveau)
            echo "${INFO} blacklisting ${SKY_BLUE}nouveau${RESET}"
            execute_script "nvidia_nouveau.sh" | tee -a "$LOG"
;;
        app_themes)
            echo "${INFO} Installing ${SKY_BLUE}GTK themes...${RESET}" | tee -a "$LOG"
            execute_script "gtk_themes.sh"
            ;;
        input_group)
            echo "${INFO} Adding user into ${SKY_BLUE}input group...${RESET}" | tee -a "$LOG"
            execute_script "InputGroup.sh"
            ;;
        fcitx)
            echo "${INFO} Configuring ${SKY_BLUE}fcitx...${RESET}" | tee -a "$LOG"
            execute_script "fcitx.sh"
            ;;
        bluetooth)
            echo "${INFO} Configuring ${SKY_BLUE}Bluetooth...${RESET}" | tee -a "$LOG"
            execute_script "bluetooth.sh"
            ;;
        thunar)
            echo "${INFO} Installing ${SKY_BLUE}Thunar file manager...${RESET}" | tee -a "$LOG"
            execute_script "thunar.sh"
            ;;
        zsh)
            echo "${INFO} Installing ${SKY_BLUE}zsh with starship...${RESET}" | tee -a "$LOG"
            execute_script "zsh.sh"
            ;;
        personal)
            echo "${INFO} Installing ${SKY_BLUE}personal packages...${RESET}" | tee -a "$LOG"
            execute_script "personal.sh"
            ;;
        *)
            echo "Unknown option: $option" | tee -a "$LOG"
            ;;
    esac
done

sleep 1

printf "\n%.0s" {1..1}

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

printf "\n%.0s" {1..2}

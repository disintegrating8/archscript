#!/bin/bash

clear
. ./common-script.sh

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/WM-Install-Scripts-$(date +%d-%H%M%S).log"

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

while true; do
    wm_choice=$(whiptail --title "Window Manager Selection" --checklist "Choose your preferred window manager.\n\nNOTE: Select only 1 Window Manager!\nINFO: spacebar to select" 12 60 3 \
        "dwm" "Suckless Dynamic Window Manager" "OFF" \
        "bspwm" "Binary Space Partitioning WM" "OFF" \
        "i3wm" "i3 Window Manager" "OFF" \
        3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then  
        echo "❌ ${INFO} You cancelled the selection. ${YELLOW}Goodbye!${RESET}" | tee -a "$LOG"
        exit 0 
    fi

    if [ -z "$wm_choice" ]; then
        whiptail --title "Error" --msgbox "You must select at least one WM to proceed." 10 60 2
        continue 
    fi

    echo "${INFO} - You selected: $wm_choice"  | tee -a "$LOG"

    wm_choice=$(echo "$wm_choice" | tr -d '"')

    # Check if multiple options were selected
    if [[ $(echo "$wm_choice" | wc -w) -ne 1 ]]; then
        whiptail --title "Error" --msgbox "You must select exactly one WM." 10 60 2
        continue  
    else
        break 
    fi
done

while true; do
    cjk_choice=$(whiptail --title "CJK Input Method Selection" --checklist "Choose your preferred input method.\n\nINFO: spacebar to select" 12 60 3 \
        "ibus" "with ibus-hangul" "OFF" \
        "fcitx5" "with fcitx5-hangul" "OFF" \
        "kime" "works the best on wayland + replaces nimf for x11" "OFF" \
        3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        echo "❌ ${INFO} You cancelled the selection. ${YELLOW}Goodbye!${RESET}" | tee -a "$LOG"
        exit 0
    fi
    
    if [ -z "$cjk_choice" ]; then
        whiptail --title "Skipping" --msgbox "Move to the next step" 10 60 2
        break 
    fi

    echo "${INFO} - You selected: $cjk_choice"  | tee -a "$LOG"
done

options_command+=(
    "app_themes" "Install GTK and QT themes?" "OFF"
    "input_group" "Add your USER to input group for some polybar? functionality?" "OFF"
    "sddm" "Install & configure SDDM login manager?" "OFF"
    "sddm_theme" "Download & Install Additional SDDM theme?" "OFF"
    "bluetooth" "Do you want script to configure Bluetooth?" "OFF"
    "thunar" "Do you want Thunar file manager to be installed?" "OFF"
    "zsh" "Install zsh shell with Oh-My-Zsh?" "OFF"
    "pokemon" "Add Pokemon color scripts to your terminal?" "OFF"
    "rog" "Are you installing on Asus ROG laptops?" "OFF"
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
sleep 1
# setup dotfiles first
echo "${INFO} Installing ${SKY_BLUE}disintegrating8/dotfiles...${RESET}"
execute_script "dotfiles.sh"
sleep 1

if [ "$wm_choice" == "dwm"]; then
    execute_script "bspwm.sh"
fi
if [ "$wm_choice" == "bspwm"]; then
    execute_script "bspwm.sh"
fi
if [ "$wm_choice" == "i3wm"]; then
    execute_script "bspwm.sh"
fi

if [ "$cjk_choice" == "ibus"]; then
    execute_script "ibus.sh"
fi
if [ "$cjk_choice" == "fcitx5"]; then
    execute_script "fcitx.sh"
fi
if [ "$cjk_choice" == "kime"]; then
    execute_script "kime.sh"
fi
 
sleep 1

# Running scripts that apply to all WM
echo "${INFO} Configuring ${SKY_BLUE}pipewire...${RESET}"
execute_script "pipewire.sh"

echo "${INFO} Installing ${SKY_BLUE}necessary fonts...${RESET}"
execute_script "fonts.sh"

echo "${INFO} Adding user into ${SKY_BLUE}input group...${RESET}" | tee -a "$LOG"
execute_script "InputGroup.sh"

# Clean up the selected options (remove quotes and trim spaces)
selected_options=$(echo "$selected_options" | tr -d '"' | tr -s ' ')

# Convert selected options into an array (splitting by spaces)
IFS=' ' read -r -a options <<< "$selected_options"

# Loop through selected options
for option in "${options[@]}"; do
    case "$option" in
        sddm)
            if check_services_running; then
                active_list=$(printf "%s\n" "${active_services[@]}")
                whiptail --title "Error" --msgbox "One of the following login services is running:\n$active_list\n\nPlease stop & disable it or DO not choose SDDM." 12 60
                exec "$0"  
            else
                echo "${INFO} Installing and configuring ${SKY_BLUE}SDDM...${RESET}" | tee -a "$LOG"
                execute_script "sddm.sh"
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
        bluetooth)
            echo "${INFO} Configuring ${SKY_BLUE}Bluetooth...${RESET}" | tee -a "$LOG"
            execute_script "bluetooth.sh"
            ;;
        thunar)
            echo "${INFO} Installing ${SKY_BLUE}Thunar file manager...${RESET}" | tee -a "$LOG"
            execute_script "thunar.sh"
            execute_script "thunar_default.sh"
            ;;
        sddm_theme)
            echo "${INFO} Downloading & Installing ${SKY_BLUE}Additional SDDM theme...${RESET}" | tee -a "$LOG"
            execute_script "sddm_theme.sh"
            ;;
        zsh)
            echo "${INFO} Installing ${SKY_BLUE}zsh with Oh-My-Zsh...${RESET}" | tee -a "$LOG"
            execute_script "zsh.sh"
            ;;
        pokemon)
            echo "${INFO} Adding ${SKY_BLUE}Pokemon color scripts to terminal...${RESET}" | tee -a "$LOG"
            execute_script "zsh_pokemon.sh"
            ;;
        rog)
            echo "${INFO} Installing ${SKY_BLUE}ROG laptop packages...${RESET}" | tee -a "$LOG"
            execute_script "rog.sh"
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

#!/bin/sh -e

# shellcheck disable=SC2034

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

command_exists() {
for cmd in "$@"; do
    export PATH="$HOME/.local/share/flatpak/exports/bin:/var/lib/flatpak/exports/bin:$PATH"
    command -v "$cmd" >/dev/null 2>&1 || return 1
done
return 0
}

checkFlatpak() {
    if ! command_exists flatpak; then
        printf "%b\n" "${YELLOW}Installing Flatpak...${RC}"
        sudo pacman -S --needed --noconfirm flatpak
        printf "%b\n" "${YELLOW}Adding Flathub remote...${RC}"
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        printf "%b\n" "${YELLOW}Applications installed by Flatpak may not appear on your desktop until the user session is restarted...${RC}"
    else
        if ! flatpak remotes | grep -q "flathub"; then
            printf "%b\n" "${YELLOW}Adding Flathub remote...${RC}"
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        else
            printf "%b\n" "${CYAN}Flatpak is installed${RC}"
        fi
    fi
}

checkAUR() {
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
}

checkArch() {
    case "$(uname -m)" in
        x86_64 | amd64) ARCH="x86_64" ;;
        aarch64 | arm64) ARCH="aarch64" ;;
        *) printf "%b\n" "${RED}Unsupported architecture: $(uname -m)${RC}" && exit 1 ;;
    esac

    printf "%b\n" "${CYAN}System architecture: ${ARCH}${RC}"
}

checkCommandRequirements() {
    ## Check for requirements.
    REQUIREMENTS=$1
    for req in ${REQUIREMENTS}; do
        if ! command_exists "${req}"; then
            printf "%b\n" "${RED}To run me, you need: ${REQUIREMENTS}${RC}"
            exit 1
        fi
    done
}

checkSuperUser() {
    # Check if running as root.
    if [[ $EUID -eq 0 ]]; then
        echo "${ERROR}  This script should ${WARNING}NOT${RESET} be executed as root!! Exiting......." | tee -a "$LOG"
        printf "\n%.0s" {1..2} 
        exit 1
    fi
    # Check if member of the sudo group.
    if ! groups | grep -q "${SUGROUP}"; then
        printf "%b\n" "${WARNING}You need to be a member of the sudo group to run me!${RC}"
        exit 1
    fi
}

checkCurrentDirectoryWritable() {
    ## Check if the current directory is writable.
    GITPATH="$(dirname "$(realpath "$0")")"
    if [ ! -w "$GITPATH" ]; then
        printf "%b\n" "${RED}Can't write to $GITPATH${RC}"
        exit 1
    fi
}

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

checkEnv() {
    checkArch
    checkCommandRequirements "curl groups sudo"
    checkCurrentDirectoryWritable
    checkSuperUser
}

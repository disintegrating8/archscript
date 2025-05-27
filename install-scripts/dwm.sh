#!/bin/bash

dwm_package=(libx11 libxinerama libxft imlib2 git unzip flameshot lxappearance-gtk3 feth polkit-gnome xclip picom dunst)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_dwm-pkgs.log"

printf "\n%s - Installing ${SKY_BLUE}necessary packages${RESET} .... \n" "${NOTE}"

for PKG1 in "${dwm_package[@]}"; do
  install_package "$PKG1" "$LOG"
done

cd "$HOME" && git clone https://github.com/ChrisTitusTech/dwm-titus.git # CD to Home directory to install dwm-titus
cd dwm-titus/
sudo make clean install

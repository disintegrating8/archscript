#!/bin/bash

dwm_package=(
  libx11
  libxinerama 
  libxft 
  imlib2
  unzip
  xclip
  rofi
  picom
  flameshot
  feh
  dunst
  polkit-gnome
  kitty
  bc
  imagemagick
  inxi 
  network-manager-applet 
  xdg-user-dirs
  xdg-utils 
  yad
  brightnessctl
)

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

cd "$HOME" && git clone https://github.com/disintegrating8/suckless.git
cd suckless/
sudo make clean install

# install sl_status
cd "$HOME/suckless/slstatus" || {
  echo "Failed to change directory to slstatus"
  exit 1
}
if sudo make clean install; then
  echo "slstatus installed successfully"
else
  echo "Failed to install slstaus"
  exit 1
fi
cd "$HOME"

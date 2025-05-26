#!/bin/bash

bspwm_package=(
  bspwm
  sxhkd
  xclip
  polybar
  rofi
  picom
  flameshot
  feh
  dunst
  polkit-gnome
  i3lock
  betterlockscreen
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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hypr-pkgs.log"

printf "\n%s - Installing ${SKY_BLUE}necessary packages${RESET} .... \n" "${NOTE}"

for PKG1 in "${bspwm_package[@]}"; do
  install_package "$PKG1" "$LOG"
done

printf "\n%.0s" {1..2}

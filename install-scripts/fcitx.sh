#!/bin/bash

fcitx_pkg=(
  fcitx5
  fcitx5-configtool
  fcitx5-gtk
  fcitx5-qt
  fcitx5-hangul
  noto-fonts-cjk
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

LOG="Install-Logs/install-$(date +%d-%H%M%S)_fcitx.log"

printf "${NOTE} Installing ${SKY_BLUE}Fcitx5${RESET} Packages...\n"
 for PKG in "${fcitx_pkg[@]}"; do
   install_package "$PKG" "$LOG"
 done

printf "\n%.0s" {1..2}

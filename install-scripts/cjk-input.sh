#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }
# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

printf "%b\n" "${YELLOW}--------------------------${RC}" 
printf "%b\n" "${YELLOW}Pick CJK Input Method ${RC}"
printf "%b\n" "${YELLOW}1. Ibus ${RC}"
printf "%b\n" "${YELLOW}2. Fcitx ${RC}"
printf "%b\n" "${YELLOW}3. Kime ${RC}"
printf "%b" "${YELLOW}Please select one: ${RC}"
read -r choice
case "$choice" in
    1)
        METHOD="ibus"
        ;;
    2)
        METHOD="fcitx5"
        ;;
    3)
        METHOD="kime"
        ;;
    *)
        printf "%b\n" "${RED}Invalid selection! Please choose 1, 2, or 3.${RC}"
        ;;
esac

echo "Installing $METHOD..."

if [ "$METHOD" = "fcitx5" ]; then
    for PKG in fcitx5-im fcitx5-hangul;do
        install_package "$PKG"
    done
fi
if [ "$METHOD" = "ibus" ]; then
    for PKG in ibus ibus-hangul;do
        install_package "$PKG"
    done
fi
if [ "$METHOD" = "kime" ]; then
    install_package kime-bin
fi

XPROFILE_FILE="$HOME/.xprofile"
ENV_CONFIG=("GTK_IM_MODULE=$METHOD" "QT_IM_MODULE=$METHOD" "XMODIFIERS=@im=$METHOD")

echo "Ensuring $METHOD starts in $XPROFILE_FILE..."
for config in "${ENV_CONFIG[@]}"; do
    if ! grep -q "$config" "$XPROFILE_FILE" 2>/dev/null; then
        echo "$config" >> "$XPROFILE_FILE"
    fi
done

printf "\n%.0s" {1..2}

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

for PKG in fcitx5-im fcitx5-hangul; do
    install_package "$PKG"
    done

XPROFILE_FILE="$HOME/.xprofile"
ENV_CONFIG=("GTK_IM_MODULE=fcitx" "QT_IM_MODULE=fcitx" "XMODIFIERS=@im=fcitx")

echo "Ensuring fcitx starts in $XPROFILE_FILE..."
for config in "${ENV_CONFIG[@]}"; do
  if ! grep -q "$config" "$XPROFILE_FILE" 2>/dev/null; then
    echo "$config" >> "$XPROFILE_FILE"
  fi
done

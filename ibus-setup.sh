#!/bin/bash

ENV_FILE="$HOME/.pam_environment"
XPROFILE_FILE="$HOME/.xprofile"
ENV_CONFIG=("GTK_IM_MODULE=ibus" "QT_IM_MODULE=ibus" "XMODIFIERS=@im=ibus")

source utils.sh
source packages.conf

echo "Installing fcitx5..."
install_packages "${FCITX[@]}"

echo "Configuring environment variables in $ENV_FILE..."
for config in "${ENV_CONFIG[@]}"; do
    if ! grep -q "$config" "$ENV_FILE" 2>/dev/null; then
        echo "$config" >> "$ENV_FILE"
    fi
done

echo "Ensuring fcitx5 starts in $XPROFILE_FILE..."
if ! grep -q "fcitx5" "$XPROFILE_FILE" 2>/dev/null; then
    echo 'fcitx5 &' >> "$XPROFILE_FILE"
fi

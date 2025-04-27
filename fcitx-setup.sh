#!/bin/bash

source utils.sh
source packages.conf

echo "Installing fcitx5..."
install_packages "${FCITX[@]}"

configure_environment() {
    local ENV_FILE="$HOME/.pam_environment"
    local XPROFILE_FILE="$HOME/.xprofile"
    local ENV_CONFIG=("INPUT_METHOD=fcitx5" "GTK_IM_MODULE=fcitx5" "QT_IM_MODULE=fcitx5" "XMODIFIERS=@im=fcitx5")

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
}

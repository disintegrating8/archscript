#!/bin/bash

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

#!/bin/bash

install_package kime-bin

XPROFILE_FILE="$HOME/.xprofile"
ENV_CONFIG=("GTK_IM_MODULE=kime" "QT_IM_MODULE=kime" "XMODIFIERS=@im=kime")

echo "Ensuring $METHOD starts in $XPROFILE_FILE..."
for config in "${ENV_CONFIG[@]}"; do
  if ! grep -q "$config" "$XPROFILE_FILE" 2>/dev/null; then
    echo "$config" >> "$XPROFILE_FILE"
  fi
done

